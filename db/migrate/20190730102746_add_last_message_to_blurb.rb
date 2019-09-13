class AddLastMessageToBlurb < ActiveRecord::Migration[5.1]
  def up
    add_column :pull_request_blurbs, :slack_message_timestamp, :string
  end

  def down
    remove_column :pull_request_blurbs, :slack_message_timestamp, :string
  end
end
