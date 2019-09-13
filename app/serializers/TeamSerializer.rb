class TeamSerializer
  include RestPack::Serializer

  attributes :id, :name, :slack_channel, :current_team

  def current_team
    @model.id == @context[:current_team_id]
  end
end
