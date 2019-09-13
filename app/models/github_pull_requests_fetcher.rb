require "retries"

class GithubPullRequestsFetcher

  def self.run(pull_request_blurbs: [])
    return [] unless pull_request_blurbs.any?
    blurbs = pull_request_blurbs

    pull_requests = blurbs.map do |b|
      begin
        Rails.cache.fetch("pull-request-#{b.github_repo}-#{b.github_id}", expires_in: 1.hour) do
          with_retries(max_tries: 5, rescue: Octokit::TooManyRequests, base_sleep_seconds: 1.0) do
            Octokit.pull_request(b.github_repo, b.github_id.to_i)
          end
        end
      rescue Octokit::Error, Octokit::InvalidRepository => e
        # byebug
        nil
      end
    end

    pull_requests.compact
  end

end
