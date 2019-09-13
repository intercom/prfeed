class AddTeamIdToPullRequestBlurbs < ActiveRecord::Migration[5.1]
  def change
    add_column :pull_request_blurbs, :team_id, :integer
  end
end
