import React from "react";
import ShowList from "./matcher/ShowList";
import MatchList from "./matcher/MatchList";

class Matcher extends React.Component {
  state = {
    shows: [],
    unmatched: [],
    matched: [],
    possibleMatches: [],
    selectedId: null,
    selectedTmsId: null
  }

  componentDidMount() {
    this.getData();
  }

  getData = () => {
    let unmatched = [];
    let matched = [];

    fetch('/admin/matching/shows')
      .then(response => response.json())
      .then(data => {
        this.setState({ unmatched, matched, shows: data });
      });
  }

  getPossibleMatches = (selectedId, title, selectedTmsId) => {
    const url = `/admin/matching/possible_matches?title=${encodeURIComponent(title)}`
    fetch(url)
      .then(response => response.json())
      .then(data => {
        const programs = data.map((match) => match.program);
        this.setState({ selectedId, selectedTmsId, selectedTitle: title, possibleMatches: programs })
      });
  }

  saveMatch = (id, tmsId) => {
    const url = '/admin/matching/match'
    const data = {
      id: id,
      tms_id: tmsId
    }

    fetch(url, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(data)
    }).then(response => response.json())
    .then(data => {
      this.setState({ possibleMatches: [] });
      this.getData();
    });
  }

  render () {
    const {matched, unmatched, shows, possibleMatches, selectedId, selectedTitle, selectedTmsId} = this.state;

    return (
      <div id='matcher' style={{
          display: 'flex',
          width: '100%'
        }}>
        <div className="originals" style={{width: 400 }}>
          <ShowList shows={shows} getPossibleMatches={this.getPossibleMatches} selectedId={selectedId}/>
        </div>
        <div className="matches">
          <MatchList matches={possibleMatches} saveMatch={this.saveMatch} showId={selectedId} showTitle={selectedTitle} selectedTmsId={selectedTmsId}/>
        </div>
      </div>
    );
  }
}

export default Matcher
