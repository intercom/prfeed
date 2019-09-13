class PullRequestSerializer
  include RestPack::Serializer

  attributes :allow_bump, :age_in_seconds, :commented_upon, :mergeable, :open, :merged, :title,
             :line_deletion_count, :line_addition_count, :repo_name, :github_id, :github_repo,
             :url, :owner, :owner_avatar_url, :owner_profile_url, :review_status,
             :last_looked_at_in_seconds, :last_updated_in_seconds, :last_looked_at_by,
             :total_number_of_comments, :mine

  def commented_upon
    @model.commented_upon?
  end

  def mergeable
    @model.mergeable?
  end

  def open
    @model.open?
  end

  def merged
    @model.merged?
  end

  def mine
    @model.owner == @context[:github_user]&.login
  end
end
