require "rails_helper"

RSpec.describe "api", :type => :request do
  let(:github_org_member) { double(org_member?: true, login: "zabraboof") }
  let(:github_org_nonmember) { double(org_member?: false, login: "stranger") }
  let(:pull_request) {
    double(
      allow_bump: true,
      age_in_seconds: 0,
      commented_upon: true,
      mergeable: true,
      open: true,
      merged: true,
      title: "",
      line_deletion_count: 0,
      line_addition_count: 0,
      repo_name: "",
      github_id: 0,
      url: "",
      owner: true,
      owner_avatar_url: "",
      owner_profile_url: "",
      review_status: "",
      last_looked_at_by: "",
      total_number_of_comments: 0,
      commented_upon?: true,
      mergeable?: true,
      open?: true,
      merged?: true,
      github_repo: "",
      last_looked_at_in_seconds: 0,
      last_updated_in_seconds: 0,
    )
  }

  it "fails with a 403 without authorization token" do
    post "/api/pull_requests", params: ''
    expect(response.status).to be(403)
    expect(JSON.parse(response.body)).to eq(
      {"error" => "Please provide your Github access token in the header of your request, i.e., 'Authorization: Token token={YOUR_TOKEN}'"}
    )
  end

  describe "with authorization token" do 
    it "does not work if the user is not a part of the github organization" do
      team = Team.create(name: "bar")
      expect(Octokit::Client).to receive(:new).with({:access_token=>"foobarbaz"}).and_return(github_org_nonmember)
      post "/api/pull_requests", 
        params: { pull_request_url: "https://github.com/org/repo/pull/111", team_name: "bar"}.to_json , 
        headers: { "Content-Type" => "application/json", "Authorization" => "Token token=foobarbaz" }
      expect(response.status).to be(403)
    end

    it "does not work if pull_request_url and team_name parameters are missing" do
      team = Team.create(name: "bar")
      expect(Octokit::Client).to receive(:new).with({:access_token=>"foobarbaz"}).and_return(github_org_member)
      post "/api/pull_requests", 
        params: {} , 
        headers: { "Content-Type" => "application/json", "Authorization" => "Token token=foobarbaz" }
      expect(response.status).to be(422)
    end

    it "works if the user is part of the github organization" do
      team = Team.create(name: "bar")
      expect(Octokit::Client).to receive(:new).with({:access_token=>"foobarbaz"}).and_return(github_org_member)
      expect(GithubPullRequestsFetcher).to receive_message_chain(:run, :map, :first).and_return(pull_request)
      expect(SlackNotifier).to receive(:post_message)
      post "/api/pull_requests", 
        params: { pull_request_url: "https://github.com/org/repo/pull/111", team_name: "bar"}.to_json , 
        headers: { "Content-Type" => "application/json", "Authorization" => "Token token=foobarbaz" }
      expect(response.status).to be(201)
    end
  end
end
