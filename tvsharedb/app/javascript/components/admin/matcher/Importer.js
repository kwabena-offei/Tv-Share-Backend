import React from "react"
import DataTable from 'react-data-table-component';
import Select from 'react-select'
import {DebounceInput} from 'react-debounce-input';

class Importer extends React.Component {
  state = {
    filterText: '',
    searchResults: [],
    dbShow: null,
    selectedNetworks: [],
    isLoading: true
  }

  onTextChange = (e) => {
    const value = e.target.value;
    this.setState({filterText: value});
    this.getPossibleMatches(value);
  }

  getPossibleMatches = (title) => {
    const url = `/admin/matching/possible_matches?title=${encodeURIComponent(title)}`
    fetch(url)
      .then(response => response.json())
      .then(data => {
        const programs = data.map((match) => match.program);
        this.setState({ searchResults: programs })
      });
  }

  onSelectItem = (data) => {
    this.setState({selectedShow: data, selectedNetwork: null})
    this.getShowFromDb(data.tmsId);
  }

  onClickSaveMatch = (show) => {
    const {selectedNetworks} = this.state;
    const {seriesId, tmsId} = show;
    const networkIds = selectedNetworks?.map((network) => {
      return network.value;
    }) || [];
    this.setState({isLoading: true})
    const url = '/admin/matching/networks/match'
    const data = {
      seriesId,
      tmsId,
      networkIds
    }
    fetch(url, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(data)
    }).then(response => response.json())
    .then(data => {
      this.setState({ dbShow: data, isLoading: false })
    });
  }

  onSelect = (selected) => {
    this.setState({selectedNetworks: selected })
  }

  getShowFromDb = (tmsId) => {
    this.setState({isLoading: true})
    const url = `/admin/matching/${tmsId}`
    fetch(url)
      .then(response => {
        if (response.status === 404) {
          return null
        } else {
          return response.json();
        }
      })
      .then(data => {
        let currentNetworkIds = data?.networks.map((network) => {
          return { label: network.display_name, value: network.id }
        }) || [];

        this.setState({ dbShow: data, selectedNetworks: currentNetworkIds, isLoading: false })
      });
  }

  importShow = (tmsId, seriesId) => {
    this.setState({isLoading: true})
    const requestOptions = {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ tms_id: tmsId, series_id: seriesId })
    };

    const url = `/admin/matching/import`
    fetch(url, requestOptions)
      .then(response => response.json())
      .then(data => {
        this.setState({ dbShow: data, isLoading: false })
      });
  }

  conditionalRowStyles = () => {
    const {selectedId} = this.props;

    return [
      {
        when: row => row.id === selectedId,
        style: {
          backgroundColor: '#e3f2fd !important',
          '&:hover': {
            cursor: 'pointer',
          },
        },
      },
    ];
  }

  render() {
    const {filterText, searchResults, } = this.state;
    const customStyles = {
      rows: {
        style: {
          minHeight: 100,
        }
      },
      cells: {
        style: {
          minWidth: 75
        }
      },
    };

    const inputStyle = {
      height: 37,
      width: '80%',
      borderRadius: 3,
      borderTopLeftRadius: 5,
      borderBottomLeftRadius: 5,
      borderTopRightRadius: 0,
      borderBottomRightRadius: 0,
      border: '1px solid #e5e5e5',
      padding: '0 32px 0 16px',
    };

    const columns = [
      {
        name: 'Poster',
        selector: 'preferred_image_uri',
        cell: (row) => {
          return row.preferredImage && <img src={row.preferredImage.uri} height={100} />
        }
      },
      {
        name: 'Title',
        selector: 'title',
        compact: true,
        sortable: true,
      },
      {
        name: 'Year',
        selector: 'releaseYear',
        sortable: true,
        compact: true
      },
      {
        name: 'Cast',
        sortable: true,
        cell: (row) => {
          return row.topCast && row.topCast.join(', ')
        }
      },
      {
        name: 'Genres',
        selector: 'genres',
        cell: (row) => {
          return row.genres && row.genres.join(', ')
        }
      },
      {
        name: 'Type',
        selector: 'entityType',
        sortable: true,
        compact: true
      }
    ]

    const GracenoteShowContainer = () => {
      const {selectedShow} = this.state;

      if (!selectedShow) {
        return '';
      }

      return (
        <div style={{display: 'flex'}}>
          <img src={selectedShow.preferredImage && selectedShow.preferredImage.uri} />

          <div style={{padding: 20}}>
            <h2>{selectedShow.title}</h2>
            <h5>{selectedShow.tmsId}</h5>
            <p>Year: {selectedShow.releaseYear}</p>
            <p>Genres: {selectedShow.genres?.join(', ')}</p>
            <p>Cast: {selectedShow.topCast?.join(', ')}</p>
            <p>{selectedShow.longDescription}</p>
          </div>
        </div>
      )
    }

    const ShowContainer = () => {
      const {networks} = this.props;
      const {selectedShow, dbShow, isLoading, selectedNetworks} = this.state;
      const options = networks && networks.map((network) => {
        return { label: network.display_name, value: network.id }
      })
      const selectedNetworkIds = dbShow && dbShow.networks.map((network) => {
        return { label: network.display_name, value: network.id }
      })

      if (isLoading && selectedShow) {
        return 'Loading...'
      }

      if (!isLoading && dbShow === null) {
        return (
          <>
            <p>Not found in TV Chat's database.</p>
            <button onClick={this.importShow.bind(this, selectedShow.tmsId, selectedShow.seriesId)}>
              Import
            </button>
          </>
        )
      }

      if (!isLoading && dbShow && dbShow.id) {
        return (
          <div>
            <p>Found in TV Chat's database</p>
            <h3>TV Chat #{dbShow.id}</h3>
            <p>Display Genres: {dbShow.display_genres?.join(', ')}</p>
            <div key={dbShow.id}>
              <p>Select a network:</p>
              <Select
                isMulti
                options={options}
                onChange={this.onSelect}
                defaultValue={selectedNetworks}
              />
              <button
                onClick={this.onClickSaveMatch.bind(this, dbShow)}
              >
                Assign Network
              </button>
            </div>
          </div>
        )
      }
      return '';
    }

    return (
      <div style={{marginTop: 56, display: 'flex'}}>
        <div style={{width: '50%'}}>
          <DebounceInput
            minLength={2}
            debounceTimeout={300}
            id="search"
            type="text"
            placeholder="Search Gracenote"
            value={filterText}
            onChange={this.onTextChange}
            style={inputStyle}
          />

          <DataTable
            fixedHeader
            striped
            conditionalRowStyles={this.conditionalRowStyles()}
            highlightOnHover
            columns={columns}
            data={searchResults}
            onRowClicked={this.onSelectItem}
            pagination
            paginationPerPage={20}
            subHeader
            customStyles={customStyles}
          />
        </div>
        <div>
          <div style={{padding: 20}}>
            <GracenoteShowContainer />
            <ShowContainer />
          </div>
        </div>
      </div>
    )
  }

}
export default Importer;
