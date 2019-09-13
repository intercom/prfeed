class TeamsController < ApplicationController
  def index
    teams = Team.all.sort_by(&:name)
    render json: ::TeamSerializer.as_json(teams, { current_team_id: current_team_id })
  end

  def create
    team = Team.find_or_create_by(name: team_params[:name])
    team.update(slack_channel: team_params[:slack_channel]) if team_params[:slack_channel]
    cookies.signed[:team_id] = team.id

    render json: ::TeamSerializer.as_json(team)
  end

  def destroy
    team = Team.find(team_params[:id])
    team.blurbs.each(&:delete)
    team.delete
    head :ok
  end

  def update
    team = Team.find(team_params[:id])
    team.update(name: team_params[:name]) if team_params[:name] && team.name != team_params[:name]
    team.update(slack_channel: team_params[:slack_channel]) if team_params[:slack_channel] && team.slack_channel != team_params[:slack_channel]
    head :ok
  end

  def set_team
    if team_params[:id]
      team = Team.find(team_params[:id])
      cookies.signed[:team_id] = team.id if team
    end

    head :ok
  end

  private def team_params
    params.require(:team).permit(:id, :name, :slack_channel)
  end
end
