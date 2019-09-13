class PullRequest
  def initialize(github_datum:, current_admin:)
    @current_admin = current_admin
    @github_datum = github_datum
    @reviews_datum = GithubReviewsFetcher.run(
      github_repo: @github_datum.base.repo.full_name,
      github_id: @github_datum.number,
    )
    @comments_datum = GithubCommentsFetcher.run(
      github_repo: @github_datum.base.repo.full_name,
      github_id: @github_datum.number,
    )
  end

  def age_in_seconds
    Time.zone.now - @github_datum.created_at
  end

  def allow_bump
    @current_admin == owner
  end

  def commented_upon?
    comments.length > 0 || reviews.length > 0
  end

  def mergeable?
    @github_datum.mergeable && @github_datum.mergeable_state == "clean"
  end

  def open?
    @github_datum.state == "open"
  end

  def merged?
    @github_datum.merged
  end

  def github_id
    @github_datum.number.to_s
  end

  def github_repo
    @github_datum.base.repo.full_name
  end

  def title
    @github_datum.title
  end

  def line_deletion_count
    @github_datum.deletions
  end

  def line_addition_count
    @github_datum.additions
  end

  def repo_name
    @github_datum.base.repo.name.capitalize
  end

  def url
    @github_datum.html_url
  end

  def owner
    @github_datum.user.login
  end

  def owner_avatar_url
    @github_datum.user.avatar_url
  end

  def owner_profile_url
    @github_datum.user.html_url
  end

  def review_status
    return if reviews.empty?
    review_states = reviews.map { |review| review[:state] }
    status = "COMMENTED"

    review_states.each do |state|
      next if state == "DIMISSED" || state == "COMMENTED"
      status = state
    end

    status
  end

  def last_looked_at_in_seconds
    activity_at = [
      comments.last && comments.last[:created_at],
      reviews.last && reviews.last[:created_at]
    ].compact.max
    Time.zone.now - activity_at if activity_at.present?
  end

  def last_looked_at_by
    activity = [comments.last, reviews.last]
      .compact
      .max_by { |activity| activity[:created_at] }

    activity[:author] if activity.present?
  end

  def last_updated_in_seconds
    Time.zone.now - @github_datum.updated_at
  end

  def total_number_of_comments
    comments.length + reviews.length
  end

  private def comments
    return [] if @comments_datum.empty?
    comments = @comments_datum.map do |comment|
      {
        author: comment.user.login,
        body: comment.body,
        created_at: comment.created_at.getlocal,
      }
    end

    comments.reject { |comment| comment[:author] == owner }
  end

  private def reviews
    return [] if @reviews_datum.empty?
    reviews = @reviews_datum.map do |review|
      {
        author: review.user.login,
        body: review.body,
        created_at: review.submitted_at&.getlocal,
        state: review.state,
      }
    end

    reviews.reject { |review| review[:author] == owner }
  end
end
