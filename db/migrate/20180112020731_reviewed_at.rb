class ReviewedAt < ActiveRecord::Migration[5.1]
  def change
    add_column :pull_request_blurbs, :first_reviewed_at, :datetime
  end
end
