require "retries"

class GithubUserFetcher

  def self.run(username:)
    Rails.cache.fetch("user-#{username}", expires_in: 1.hour) do
      with_retries(max_tries: 5, rescue: Octokit::TooManyRequests, base_sleep_seconds: 1.0) do
        Octokit.user(username)
      end
    end
  end

end