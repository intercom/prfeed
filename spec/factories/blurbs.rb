FactoryBot.define do
  factory :blurbs, class: "PullRequestBlurb" do
    association :team

    github_id { "1" }
    github_repo { "org/org-ruby" }
    active { true }
  end
end
