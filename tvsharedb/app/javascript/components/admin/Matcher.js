import React from "react"
import PropTypes from "prop-types"
class Matcher extends React.Component {
  state = {
    unmatched: [],
    matched: [],
    possibleMatches: []
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
        data.forEach((show) => {
          show.tmsId ? matched.push(show) : unmatched.push(show);
          this.setState({ unmatched, matched })
        })
      });
  }

  getPossibleMatches = (title) => {
    fetch(`/admin/matching/possible_matches?title=${title}`)
      .then(response => response.json())
      .then(data => {
        this.setState({ possibleMatches: data })
      });
  }

  render () {
    const {matched, unmatched, possibleMatches} = this.state;

    return (
      <div id='matcher' style={{
          display: 'flex',
          width: '100%'
        }}>
        <div className="originals" style={{width: '50%'}}>
          <ul>
            {unmatched.map(show => {
              return <li key={show.id} onClick={() => { this.getPossibleMatches(show.title)} }>{show.title}</li>
            })
          }
          </ul>
        </div>
        <div className="matches"  style={{width: '50%'}}>
          <ul>
            {possibleMatches.map(match => {
              return <li>{match.program.title}</li>
            })
          }
          </ul>
        </div>
      </div>
    );
  }
}

export default Matcher
