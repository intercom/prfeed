class PullRequestBlurb < ApplicationRecord

  belongs_to :team, required: false

  scope :active, -> { where(active: true).select("DISTINCT ON (github_id, github_repo) *") }
  scope :inactive, -> { where(active: false) }

  def self.extract_github_repo(url)
    url.match(/#{Rails.application.secrets.github_organization}\/([^\/]*)/).to_s
  end

  def self.extract_github_id(url)
    matches = /pull\/(\d*)(\D*|$)/.match(url)
    return matches[1] if matches.present?
    1 # default
  end

  def self.update_blurbs_for_closed_pull_requests(github_ids)
    blurbs_to_update = active.where(github_id: github_ids)
    blurbs_to_update.each { |b| b.update!(active: false) }
  end

  def self.update_first_reviewed_at_if_necessary(github_ids)
    blurbs_to_update = active.where(github_id: github_ids, first_reviewed_at: nil)
    blurbs_to_update.each { |b| b.set_first_reviewed_at }
  end

  def reviews
    GithubReviewsFetcher.run(
      github_repo: github_repo,
      github_id: github_id,
    )
  end

  def set_first_reviewed_at
    update!(first_reviewed_at: review&.submitted_at)
  end

  private def review
    reviews&.first
  end
end
