class Team < ApplicationRecord

  has_many :blurbs, class_name: "PullRequestBlurb"

end
