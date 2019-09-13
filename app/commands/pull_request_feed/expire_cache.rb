# frozen_string_literal: true

module PullRequestFeed
  class ExpireCache < Mutations::Command

    required do
      duck :blurb, class: PullRequestBlurb
    end

    def execute
      Rails.cache.delete(pull_request_cache_key)
      Rails.cache.delete(pull_request_review_cache_key)
      Rails.cache.delete(pull_request_comments_cache_key)
    end

    protected def github_repo
      blurb.github_repo
    end

    protected def pull_request_number
      blurb.github_id
    end

    protected def pull_request_cache_key
      "pull-request-#{github_repo}-#{pull_request_number}"
    end

    protected def pull_request_review_cache_key
      "pull-request-review-#{github_repo}-#{pull_request_number}"
    end

    protected def pull_request_comments_cache_key
      "pull-request-comments-#{github_repo}-#{pull_request_number}"
    end

  end
end
