class ApiController < ApplicationController

  class MissingParameterError < StandardError; end
  class MissingAuthorizationTokenError < StandardError; end
  class NotAuthorizedError < StandardError; end
  class InvalidTokenError < StandardError; end

  GITHUB_ORGANIZATION = Rails.application.secrets.github_organization

  before_action :authenticate!

  def create_pull_request_blurb
    blurb = team.blurbs.create!(
      github_repo: PullRequestBlurb.extract_github_repo(pull_request_url),
      github_id: PullRequestBlurb.extract_github_id(pull_request_url),
    )

    pull_request = GithubPullRequestsFetcher
      .run(pull_request_blurbs: [blurb])
      .map { |datum| PullRequest.new(github_datum: datum, current_admin: current_admin) }
      .first

    unless pull_request
      blurb.update!(active: false)
      return head :not_found
    end

    SlackNotifier.post_message(
      channel: team.slack_channel,
      pull_request: pull_request,
      pull_request_blurb: blurb
    )

    render json: ::PullRequestSerializer.as_json(pull_request), status: :created
  rescue MissingParameterError
    render json: { error: "You must provide a pull request Github URL and a team name, i.e., '{ 'pull_request_url': 'some_url', 'team_name': 'some_team' }'" }, status: :unprocessable_entity
  end

  private def authenticate!
    token, _ = ActionController::HttpAuthentication::Token.token_and_options(request)
    raise MissingAuthorizationTokenError if token.nil?
    user = github_user_from_token(token)
    raise NotAuthorizedError unless user.org_member?(GITHUB_ORGANIZATION, user.login)
  rescue MissingAuthorizationTokenError
    render json: { error: "Please provide your Github access token in the header of your request, i.e., 'Authorization: Token token={YOUR_TOKEN}'" }, status: :forbidden
  rescue NotAuthorizedError
    render json: { error: "You must be member of the #{GITHUB_ORGANIZATION} Github organization to use this API" }, status: :unauthorized
  end

  def github_user_from_token(token)
    Octokit::Client.new(access_token: token)
  end

  private def team
    raise MissingParameterError unless pull_request_params[:team_name]
    @team ||= Team.find_by_name(pull_request_params[:team_name])
  end

  private def pull_request_url
    raise MissingParameterError unless pull_request_params[:pull_request_url]
    pull_request_params[:pull_request_url]
  end

  private def pull_request_params
    params.permit(:pull_request_url, :team_name)
  end
end
