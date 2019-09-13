import React, { Component } from 'react';
import { Link } from 'react-router-dom'
import '../stylesheets/App.css';
import Form from '../components/Form';
import PullRequest from '../components/PullRequest';
import Teams from '../components/Teams';
import ToggleNotificationsButton from '../components/ToggleNotificationsButton'

import differenceBy from 'lodash.differenceby'
import reject from 'lodash.reject'

class PrFeed extends Component {
  constructor() {
    super()
    this.state = {
      errorMessage: null,
      showApprovedPullRequests: false,
      pullRequests: [],
    }
    this.getPullRequests = this.getPullRequests.bind(this)
    this.addPullRequest = this.addPullRequest.bind(this)
    this.toggleShowApprovedPullRequests = this.toggleShowApprovedPullRequests.bind(this)
    window.getPullRequests = () => this.getPullRequests()
  }

  componentWillMount() {
    this.getPullRequests()
    this.poll()
  }

  componentWillUnmount() {
    clearTimeout(this.timeout)
  }

  poll() {
    this.timeout = setInterval(() => this.getPullRequests(), 5000)
  }

  addPullRequest(pullRequest) {
    let { pullRequests } = this.state
    let updatedPullRequests = pullRequests.concat([pullRequest])
    this.setState({ pullRequests: updatedPullRequests })
  }

  async getPullRequests() {
    let response = await window.fetch('pull_requests', { credentials: 'include' })

    if (response.status === 502) {
      return this.setState({
        errorMessage: 'Github API rate limit has been exceeded for the hour'
      })
    }

    let pullRequests = await response.json()

    this.setState({ pullRequests: pullRequests, errorMessage: null })
  }

  componentDidUpdate (prevProps, prevState) {
    if (localStorage.getItem('justChangedTeams')) return;

    let oldPRs = prevState.pullRequests
    if (oldPRs.length === 0) return;

    let currentPRs = this.state.pullRequests

    let newPRs = differenceBy(currentPRs, oldPRs, 'github_id')
    let newPRsThatArentMine = reject(newPRs, 'mine')

    newPRsThatArentMine.forEach((pullRequest) => {
      if (localStorage.getItem('sendNotifications')) {
        new Notification(
          pullRequest.title,
          {
            icon: pullRequest.owner_avatar_url,
            body: `In ${pullRequest.github_repo} by @${pullRequest.owner}`,
          }
        )
      }
    })
  }

  toggleShowApprovedPullRequests() {
    let { showApprovedPullRequests } = this.state
    this.setState({ showApprovedPullRequests: !showApprovedPullRequests })
  }

  render() {
    let { errorMessage, pullRequests, showApprovedPullRequests } = this.state

    if (errorMessage) {
      return (
        <div className="app">
          <div className="app__error">{errorMessage}</div>
        </div>
      )
    }

    let pullRequestsToDisplay = showApprovedPullRequests
        ? pullRequests
        : pullRequests.filter(pullRequest => {
          return pullRequest.review_status !== "APPROVED"
        })

    return (
      <div className="app">
        <Form addPullRequest={this.addPullRequest} />
        <div className="flex teams">
          <div className="flex column">
            <Teams />
            <Link to='/manage_teams'className="app__manage-teams-button link">Manage teams</Link>
          </div>
          <div className="flex column">
            <button className="button o__secondary" onClick={this.toggleShowApprovedPullRequests}>
              {showApprovedPullRequests
                ? 'Show only unapproved'
                : 'Show all'}
            </button>

            <ToggleNotificationsButton />
          </div>
        </div>
        <div className="pull-requests">
          {pullRequests.length && pullRequestsToDisplay
            ? pullRequestsToDisplay.map((pr) => {
                return <PullRequest pullRequest={pr} key={pr.github_id}/>
              })
            : <div className="flex column">
                <p>No pull requests</p>
                <img src="https://media.giphy.com/media/naXyAp2VYMR4k/giphy.gif" alt="Loading.." />
              </div>}
        </div>
      </div>
    );
  }
}

export default PrFeed;
