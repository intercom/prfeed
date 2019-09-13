desc "delete inactive pull request blurbs"
task delete_inactive_pull_request_blurbs: :environment do
  PullRequestBlurb.inactive.each(&:delete)
end
