## PRFeed
This is a Github __pull request feed__ that integrates with Slack. It aims to automate some of the things we do in the code review process (e.g., manual reposting) and improve the visibility of outstanding pull requests.

Features include:
1. A list of outstanding, open PRs
2. Post PRs to various Slack channels (i.e., organize by teams)
3. API available listing a PR (i.e., write a script to list a PR on PRFeed)

## Setting up

##### Ruby version: `2.4.6`
##### Rails version: `5.2.3`
##### Node version: `7`
##### Database: postgresql (don't forget to start up postgres)

You will need to configure `Octokit`, `Warden::GitHub::Rails`, and `Slack`.

1. `Octokit` requires an [`access_token`](https://github.com/octokit/octokit.rb#oauth-access-tokens) with repo access in order to read pull request data from Github. Make sure the `access_token` belongs to an account that has access to repositories you want integrated. The `secrets.yml` file will read the value of the access token from `ENV["GITHUB_TOKEN"]`.

2. `Warden::GitHub::Rails` provides authentication so that only members of your Github organization can access the PRFeed. It requires a `github_organization`, `client_id` and `client_secret` - procure these from [creating an OAuth application in you Github settings](https://github.com/settings/applications/new). The `secrets.yml` file will read the value of the ID and secret from `ENV["GITHUB_ORG"]`, `ENV["GITHUB_CLIENT_ID"]` and ENV["GITHUB_CLIENT_SECRET"].

3. `Slack` requires a [`slack_api_token`](https://api.slack.com/slack-apps) to post in channels of your Slack account. Be sure to invite the bot to the various channels.

```
bundle install
yarn
rake db:setup
rails server
```

## How to use

### *Add a team and configure Slack channel*

1. Click the `Manage teams` by the teams dropdown
1. Add team name
1. Add Slack channel for code-reviews (optional)
1. Press `enter`

### *Post a PR*

  1. Choose your team in the teams dropdown
  1. Paste URL in the input field
  1. Press `enter`

### *Repost a PR*

1. Press `bump`. Bumping will repost in Slack and will look something like this:

### *PR posts*

1. PR status updates will happen automatically:
    - `Pending` = there are no comments, approvals, or changes requested
    - `Commented` = there are comments
    - `Changes Requested` = changes have been requested
    - `Approved` = an approval has been granted
    - PRs will disappear from the feed when they've been merged or closed
    - Dismissed or stale reviews will revert the status of the PR to the previous state: `Pending`, `Commented`, or `Changes Requested`
2. Toggle the button below the input to show all or show only unapproved PRs

### Run tests locally

```
bundle exec rspec
```
Some tests are also run with:
```
rake test
```
