class PullRequestsController < ApplicationController

  def index
    pull_requests = GithubPullRequestsFetcher
      .run(pull_request_blurbs: current_team.blurbs.active.sort_by(&:created_at))
      .map { |datum| PullRequest.new(github_datum: datum, current_admin: current_admin) }

    closed_pull_requests_ids = pull_requests
      .reject(&:open?)
      .map(&:github_id)

    PullRequestBlurb.update_first_reviewed_at_if_necessary(pull_requests.map(&:github_id))

    PullRequestBlurb.update_blurbs_for_closed_pull_requests(closed_pull_requests_ids)

    render json: ::PullRequestSerializer.as_json(pull_requests.select(&:open?), github_user: github_user)
  rescue Octokit::TooManyRequests
    render json: { error: "Github API rate limit exceeded" }, status: :bad_gateway
  end

  def create
    blurb = current_team.blurbs.create!(
      github_repo: PullRequestBlurb.extract_github_repo(pull_request_params[:url]),
      github_id: PullRequestBlurb.extract_github_id(pull_request_params[:url]),
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
      channel: current_team.slack_channel,
      pull_request: pull_request,
      pull_request_blurb: blurb
    )
    render json: ::PullRequestSerializer.as_json(pull_request), github_user: github_user
  end

  def bump
    blurb = PullRequestBlurb.where(
      "github_repo = ? and github_id = ?",
      pull_request_blurb_params[:github_repo],
      pull_request_blurb_params[:github_id]
    ).first

    pull_request = GithubPullRequestsFetcher
      .run(pull_request_blurbs: [blurb])
      .map { |datum| PullRequest.new(github_datum: datum, current_admin: current_admin) }
      .first

    if pull_request
      SlackNotifier.post_message(
        channel: current_team.slack_channel,
        pull_request: pull_request,
        pull_request_blurb: blurb,
        bump: true
      )
    end

    head :ok
  end

  private def pull_request_params
    params.require(:pull_request).permit(:url)
  end

  private def pull_request_blurb_params
    params.require(:pull_request_blurb).permit(:github_repo, :github_id)
  end

end
