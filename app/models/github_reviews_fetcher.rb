require "retries"

class GithubReviewsFetcher

  def self.run(github_repo:, github_id:)
    Rails.cache.fetch("pull-request-review-#{github_repo}-#{github_id}", expires_in: 1.hour) do
      with_retries(max_tries: 5, rescue: Octokit::TooManyRequests, base_sleep_seconds: 1.0) do
        begin
          Octokit.pull_request_reviews(github_repo, github_id.to_i)
        end
      end
    end
  rescue Octokit::NotFound => e
    nil
  end

end
