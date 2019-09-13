class AddPullRequestBlurbs < ActiveRecord::Migration[5.1]
  def change
    create_table :pull_request_blurbs do |t|
      t.string :github_id, null: false
      t.string :github_repo, null: false
      t.boolean :active, default: true, null: false
      t.timestamps
    end
  end
end
