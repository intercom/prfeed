class ApplicationController < ActionController::Base
  def index
    render :index
  end

  def current_team_id
    cookies.signed[:team_id] || Team.first.id
  end

  def current_admin
    github_user.login if github_user
  end

  def current_team
    Team.find(current_team_id)
  end
end
