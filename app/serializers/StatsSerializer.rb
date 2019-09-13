class StatsSerializer
  include RestPack::Serializer

  attributes :id, :github_id, :github_repo, :created_at, :created_at_date, :created_at_week, :approved_at, :time_to_review

  def approved_at
    @model.first_reviewed_at
  end

  def time_to_review
    return if approved_at.nil?
    ((approved_at.to_datetime - created_at.to_datetime) * 1.day).to_i / 60
  end

  def created_at_date
    created_at.to_date
  end

  def created_at_week
    created_at.strftime("%U").to_i
  end
end
