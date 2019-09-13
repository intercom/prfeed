class AddTeams < ActiveRecord::Migration[5.1]
  def change
    create_table :teams do |t|
      t.string :name, null: false
      t.string :slack_channel
      t.timestamps
    end
  end
end
