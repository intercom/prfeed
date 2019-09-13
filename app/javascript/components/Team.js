import React, { Component } from 'react';
import '../stylesheets/Team.css';

export default class Team extends Component {
  constructor() {
    super()
    this.state = {
      showEditForm: false,
      formName: '',
      formSlackChannel: '',
    }
    this.deleteTeam = this.deleteTeam.bind(this)
    this.toggleEditForm = this.toggleEditForm.bind(this)
    this.handleChange = this.handleChange.bind(this)
    this._onKeyPress = this._onKeyPress.bind(this)
  }

  async deleteTeam() {
    let { team } = this.props;
    if (window.confirm(`Are you sure you want to delete team ${team.name}?`)) {
      await fetch(`teams/${team.id}`, {
        credentials: 'include',
        method: 'DELETE',
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          id: team.id,
        })
      })
      this.props.getTeams();
    }
  }

  toggleEditForm() {
    let { showEditForm } = this.state
    this.setState({ 
      showEditForm: !showEditForm,
      formName: '',
      formSlackChannel: '',
    })
  }

  _onKeyPress(event) {
    if (event.key === 'Enter') {
      this.confirmAndSave();
    }
  }

  handleChange(event) {
    let inputData = event.target.dataset.name;
    switch(true) {
      case inputData === 'team_name_edit':
        return this.setState({ formName: event.target.value });
      case inputData === 'team_slack_edit':
        return this.setState({ formSlackChannel: event.target.value });  
      default:
        return;
    }
  }

  async confirmAndSave() {
    let { team } = this.props;
    let { formName, formSlackChannel } = this.state;
    let confirmationMessage = `Are you sure you want to save name as ${formName || team.name} and slack channel as ${formSlackChannel || team.slack_channel}?`
    if (window.confirm(confirmationMessage)) {
      await fetch(`teams/${team.id}`, {
        credentials: 'include',
        method: 'PUT',
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          id: team.id,
          name: formName,
          slack_channel: formSlackChannel,
        })
      })
      this.props.getTeams();
      this.setState({ showEditForm: false });
    }
  }
  
  render() {
    let { team } = this.props;
    let { showEditForm } = this.state;
    return(
      <tr>
        <td>
          {showEditForm
            ? <input
                className={`form__input`}
                data-name="team_name_edit"
                onKeyPress={this._onKeyPress}
                onChange={this.handleChange}
                placeholder={team.name}
                type="text"
                value={this.state.formName} />
            : team.name
          }
        </td>
        <td>
          {showEditForm
            ? <input
                className={`form__input`}
                data-name="team_slack_edit"
                onKeyPress={this._onKeyPress}
                onChange={this.handleChange}
                placeholder={team.slack_channel}
                type="text"
                value={this.state.formSlackChannel} />
            : team.slack_channel 
          }
        </td>        
        <td className="team__button" onClick={this.toggleEditForm}>
          <span className="link">edit</span>
        </td>
        <td className="team__button" onClick={this.deleteTeam}>
          <span className="link">delete</span>
        </td>
      </tr>
    );
  }
};