class IndexPullRequestBlurbsOnActive < ActiveRecord::Migration[5.1]

  # Most PR in the data will not be active, and increasingly so as more
  # and more PR get added to the database. The number of 'active: false'
  # will always be significantly smaller than 'active: true'.
  #
  # On a random Friday evening (GMT), there were 2630 total blurb records.
  # 2587 of them were inactive, >98%.
  #
  # Even with just several thousand records, having an index to fetch the
  # active blurbs - the most interesting ones for this app - is useful.

  def up
    change_table(:pull_request_blurbs, bulk: true) do |t|
      t.index [:active], name: "index_pull_request_blurbs_on_active", using: :btree
    end
  end

  def down
    change_table(:pull_request_blurbs, bulk: true) do |t|
      t.remove_index [:active]
    end
  end
end
