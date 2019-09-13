require 'rails_helper'

RSpec.describe PullRequestFeed::ExpireCache do
  let(:pull_request_cache_key) { "pull-request-#{blurb.github_repo}-#{blurb.github_id}" }
  let(:pull_request_review_cache_key) { "pull-request-review-#{blurb.github_repo}-#{blurb.github_id}" }
  let(:pull_request_comments_cache_key) { "pull-request-comments-#{blurb.github_repo}-#{blurb.github_id}" }
  let!(:blurb) { FactoryBot.create(:blurbs)}
  subject { described_class.run!(blurb: blurb) }

  before do
    Rails.cache.write(pull_request_cache_key, "test")
    Rails.cache.write(pull_request_review_cache_key, "test")
    Rails.cache.write(pull_request_comments_cache_key, "test")
  end

  it "clears the cache" do
    expect(Rails.cache.exist?(pull_request_cache_key)).to eq(true)
    expect(Rails.cache.exist?(pull_request_comments_cache_key)).to eq(true)
    expect(Rails.cache.exist?(pull_request_review_cache_key)).to eq(true)
    subject
    expect(Rails.cache.exist?(pull_request_cache_key)).to eq(false)
    expect(Rails.cache.exist?(pull_request_comments_cache_key)).to eq(false)
    expect(Rails.cache.exist?(pull_request_review_cache_key)).to eq(false)
  end
end
