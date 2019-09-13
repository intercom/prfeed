import React, { Component } from 'react';
import '../stylesheets/Teams.css';

export default class Teams extends Component {
  constructor() {
    super()
    this.state = {
      teams: [],
    }
    this.setTeam = this.setTeam.bind(this)
  }

  componentWillMount() {
    this.getTeams()
  }

  async getTeams() {
    let response = await window.fetch('teams', { credentials: 'include' })
    let teams = await response.json()
    this.setState({ teams: teams })
  }

  async setTeam(event) {
    let teamId = event.target.options[event.target.selectedIndex].value
    await fetch('teams/set', {
      credentials: 'include',
      method: 'POST',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        team: {
          id: teamId,
        }
      })
    })

    this.temporarilyDisableNotifications()
  }

  /**
   * HACK: Naively prevent notifications from showing up when you change teams.
   */
  temporarilyDisableNotifications () {
    localStorage.setItem('justChangedTeams')
    setTimeout(() => localStorage.removeItem('justChangedTeams'), 5000)
  }

  render() {
    let { teams, showTeamForm } = this.state
    return (
      <div className="flex baseline">
        Team: <select onChange={this.setTeam} className="teams__select">
          {teams.map((team) => {
            return <option key={team.id} value={team.id} selected={team.current_team}>{team.name}</option>
          })}
        </select>
      </div>
    );
  }
}
