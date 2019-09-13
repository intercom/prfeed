import React, { Component } from 'react';
import '../stylesheets/PullRequest.css';
import { Route } from 'react-router-dom';

class PullRequest extends Component {
  constructor() {
    super()
    this.bumpPullRequest = this.bumpPullRequest.bind(this)
    this.handleAvatarClick = this.handleAvatarClick.bind(this)
  }

  getAvatarClassName() {
    let { pullRequest } = this.props
    if (pullRequest.mergeable) {
      return 'o__mergeable'
    }
  }

  getReviewStatus() {
    let { pullRequest } = this.props
    let reviewStatus = pullRequest.review_status
    if (pullRequest.merged) {
      return 'merged'
    } else if (reviewStatus === "APPROVED") {
      return 'approved'
    } else if (reviewStatus === "CHANGES_REQUESTED") {
      return 'changes requested'
    } else if (reviewStatus === "COMMENTED" || pullRequest.commented_upon) {
      return 'commented'
    } else  {
      return 'pending'
    }
  }

  getStatusClassName() {
    let status = this.getReviewStatus()
    if (status === 'merged') {
      return 'o__merged'
    } else if (status === 'approved') {
      return 'o__approved'
    } else if (status === 'changes requested') {
      return 'o__change'
    } else if (status === 'commented') {
      return 'o__commented'
    } else {
      return 'o__pending'
    }
  }

  getAge(ageInSeconds) {
    if (ageInSeconds < 60) {
      return 'just now'
    } else if (ageInSeconds <= 119) {
      return 'a minute ago'
    } else if (ageInSeconds <= 3540) {
      return `${Math.floor(ageInSeconds/60)} minutes ago`
    } else if (ageInSeconds <= 7100) {
      return 'an hour ago'
    } else if (ageInSeconds <= 82800) {
      return `${Math.floor((ageInSeconds+99)/3600)} hours ago`
    } else if (ageInSeconds <= 172000) {
      return 'a day ago'
    } else if (ageInSeconds <= 518400) {
      return `${Math.floor((ageInSeconds+800)/(60*60*24))} days ago`
    } else if (ageInSeconds <= 1036800) {
      return 'a week ago'
    } else {
      return 'too damn long ago'
    }
  }

  bumpPullRequest(e) {
    e.preventDefault()
    let { pullRequest } = this.props
    fetch('pull_requests/bump', {
      credentials: 'include',
      method: 'POST',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        pull_request_blurb: {
          github_repo: pullRequest.github_repo,
          github_id: pullRequest.github_id
        }
      })
    })
  }

  renderMore() {
    let { pullRequest } = this.props

    let hasDetails = pullRequest.last_looked_at_by ||
      (pullRequest.last_looked_at_by &&
       pullRequest.last_looked_at_in_seconds)

    if (!hasDetails) { return null }

    return (
      <details className="pull-request__details">
        <summary>more</summary>
        {pullRequest.last_looked_at_by && pullRequest.last_looked_at_in_seconds
          ? <div className="pull-request__detail pull-request__age">
              last reviewed by: <br/>
              <b>{pullRequest.last_looked_at_by} {this.getAge(pullRequest.last_looked_at_in_seconds)}</b>
            </div>
          : null}

        {pullRequest.total_number_of_comments > 0
          ? <div className="pull-request__detail pull-request__age">
              total number of comments: <b>{pullRequest.total_number_of_comments}</b>
            </div>
          : null}
      </details>
    )
  }

  handleAvatarClick() {

  }

  render() {
    let { pullRequest } = this.props
    return (
      <div className="pull-request__wrapper flex">
        <div className="pull-request__tabs">
          {this.renderMore()}
          <div className="pull-request__repo-name">{pullRequest.repo_name}</div>
        </div>
        <div className="flex column pull-request-avatar-wrapper">
          <Route render={({ history}) => (
            <img
              src={pullRequest.owner_avatar_url}
              className={`pull-request pull-request__owner-avatar ${this.getAvatarClassName()}`}
              alt="avatar"
              onClick={() => { history.push(`profile/${pullRequest.owner}`) } }/>
          )} />
        </div>
        <a href={pullRequest.url} className="pull-request" target="_blank">
          <div className="flex column pull-request__summary">
            <div className="flex baseline">
              <div className="pull-request__owner">{pullRequest.owner}</div>
              {pullRequest.last_updated_in_seconds
                ? <div className="pull-request__age">
                    <b>updated</b> {this.getAge(pullRequest.last_updated_in_seconds)}
                  </div>
                : <div className="pull-request__age">
                    opened {this.getAge(pullRequest.age_in_seconds)}
                </div>}
            </div>
            <div className="flex baseline">
              <div className="pull-request__title">{pullRequest.title}</div>
              <div className="flex pull-request__line-count">
                <div className="addition">+{pullRequest.line_addition_count}</div>
                <div className="deletion">-{pullRequest.line_deletion_count}</div>
              </div>
            </div>
            <div className={`pull-request__status ${this.getStatusClassName()}`}>{this.getReviewStatus()}</div>
            {pullRequest.allow_bump && pullRequest.review_status !== "APPROVED"
              ? <button className="pull-request__bump" onClick={this.bumpPullRequest}>
                  <i>bump</i>
                </button>
              : null}
            </div>

        </a>
      </div>
    );
  }
}

export default PullRequest;
