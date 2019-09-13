import React, { Component } from 'react';
import { Link } from 'react-router-dom'
import '../stylesheets/ManageTeams.css';
import Team from '../components/Team';

export default class ManageTeams extends Component {
  constructor() {
    super()
    this.state = {
      teams: [],
      showTeamForm: false,
      teamNamePlaceholder: 'name your team',
      teamName: '',
      slackChannelPlaceholder: 'slack channel (opt)',
      slackChannel: '',
      teamFormErrorMessage: null,
      teamFormClassName: '',
    }
    this.getTeams = this.getTeams.bind(this)
    this.toggleShowTeamForm = this.toggleShowTeamForm.bind(this)
    this.handleSubmit = this.handleSubmit.bind(this)
    this.handleChange = this.handleChange.bind(this)
  }

  componentWillMount() {
    this.getTeams()
  }

  async getTeams() {
    let response = await window.fetch('teams', { credentials: 'include' })
    let teams = await response.json()
    this.setState({ teams: teams })
  }

  toggleShowTeamForm() {
    let { showTeamForm } = this.state
    this.setState({ showTeamForm: !showTeamForm })
  }

  handleChange(event) {
    if (event.target.dataset.name === 'team_name') {
      this.setState({
        teamName: event.target.value,
        teamFormClassName: '',
        teamFormErrorMessage: null,
      })
    } else if (event.target.dataset.name === 'slack_channel') {
      this.setState({
        slackChannel: event.target.value,
        teamFormClassName: '',
        teamFormErrorMessage: null,
      })
    }
  }

  async handleSubmit(event) {
    event.preventDefault();
    let { teamName, slackChannel } = this.state
    if (teamName.length === 0) {
      this.setState({
        teamName: '',
        slackChannel: '',
        teamFormClassName: 'o__error',
        teamFormErrorMessage: 'Team required',
      })
      return
    }
    await fetch('teams', {
      credentials: 'include',
      method: 'POST',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        team: {
          name: teamName,
          slack_channel: slackChannel,
        }
      })
    })
    await this.getTeams()
    this.setState({
      teamName: '',
      slackChannel: '',
    });
    this.toggleShowTeamForm()
  }

  render() {
    let { teams, showTeamForm } = this.state
    return(
      <div className="flex column">
        <Link to='/'><span role="img" className="manage-teams__home-button link">Home</span></Link>
        <h2 className="manage-teams__h2">Teams</h2>
        <table>
          <thead>
            <tr>
              <td><b>Name</b></td>
              <td><b>Slack Channel</b></td>
              <td><b className="manage-teams__empty-td">Edit</b></td>
              <td><b className="manage-teams__empty-td">Delete</b></td>
            </tr>
          </thead>
          <tbody>
            {teams.map((team) => {
              return <Team 
                getTeams={this.getTeams} 
                key={team.id} 
                team={team} />
            })}
          </tbody>
        </table>
        {showTeamForm
          ? <form className="form flex o__team" onSubmit={this.handleSubmit}>
              <div className="team">
                <input
                  className={`form__input ${this.state.teamFormClassName}`}
                  data-name="team_name"
                  onChange={this.handleChange}
                  placeholder={this.state.teamFormErrorMessage || this.state.teamNamePlaceholder}
                  type="text"
                  value={this.state.teamName} />

                <input
                  className="form__input o__slack-channel"
                  data-name="slack_channel"
                  onChange={this.handleChange}
                  placeholder={this.state.slackChannelPlaceholder}
                  type="text"
                  value={this.state.slackChannel} />
              </div>
              <input type="submit"  className='form__submit o__team'/>
              <div className="teams__button" onClick={this.toggleShowTeamForm}>
                <b>✖︎</b>
              </div>
            </form>
          : <button className="manage-teams__add-team-button button" onClick={this.toggleShowTeamForm}>
              Add a team
            </button>
        }
      </div>
    );
  }
};