require "rails_helper"

describe SlackNotifier, type: :model do
  let(:client) { double("::Slack::Web::Client") }
  let(:channel) { "team-people-eng" }
  let(:team) { FactoryBot.create(:team, id: 1, name: "team1", slack_channel: channel) }
  let!(:blurb) { FactoryBot.create(:blurbs, team: team, github_repo: "foo/bar", slack_message_timestamp: "1.23456") }
  let(:pull_request_datum) {
    double(
      title: "Do thing",
      additions: 10,
      deletions: 5,
      html_url: "foo.html",
      url: "foo",
      user: double(
        login: "foo",
        avatar_url: "foo.jpg",
      ),
      base: double(
        repo: double(
          full_name: "Full name",
        )
      ),
      number: 1,
      owner: "foo",
      owner_avatar_url: "foo.jpg"
    )
  }
  let(:pull_request) { PullRequest.new(github_datum: pull_request_datum, current_admin: pull_request_datum.user.login) }
  let(:post_response) { { "ok" => true, "ts" => "12345.678" } }

  before do
    allow(Slack::Web::Client).to receive(:new).and_return(client)
    allow(client).to receive(:chat_postMessage).and_return(post_response)
    allow(client).to receive(:reactions_add)
    allow(GithubReviewsFetcher).to receive(:run).and_return([])
    allow(GithubCommentsFetcher).to receive(:run).and_return([])
  end

  context "#post_message" do
    let(:expected_message) { "#{pull_request.title} `+#{pull_request.line_addition_count} -#{pull_request.line_deletion_count}`: \n" + pull_request.url }

    it "posts a message" do
      expect(client).to receive(:chat_postMessage).with(
        channel: "##{channel}",
        as_user: false,
        username: pull_request.owner,
        icon_url: pull_request.owner_avatar_url,
        text: expected_message
      )
      SlackNotifier.post_message(channel: channel, pull_request: pull_request, pull_request_blurb: blurb, bump: false)
    end

    it "doesn't post a message without a channel" do
      expect(client).not_to receive(:chat_postMessage)
      SlackNotifier.post_message(channel: nil, pull_request: pull_request, pull_request_blurb: blurb, bump: false)
    end

    it "posts a bump message" do
      expect(client).to receive(:chat_postMessage).with(
        channel: "##{channel}",
        as_user: false,
        username: pull_request.owner,
        icon_url: pull_request.owner_avatar_url,
        text: "*BUMP - this PR is ready for another review* \n" + expected_message
      )
      SlackNotifier.post_message(channel: channel, pull_request: pull_request, pull_request_blurb: blurb, bump: true)
    end

    it "updates the blurb" do
      expect(blurb.slack_message_timestamp).not_to eq(post_response["ts"])
      SlackNotifier.post_message(channel: channel, pull_request: pull_request, pull_request_blurb: blurb, bump: false)
      expect(blurb.slack_message_timestamp).to eq(post_response["ts"])
    end
  end

  shared_examples "adds a reaction" do
    it "adds a reaction" do
      expect(client).to receive(:reactions_add).with(name: reaction_name, channel: "##{channel}", timestamp: blurb.slack_message_timestamp)
      add_reaction
    end

    context "with a channel with a leading #" do
      let(:channel) { "#team-people-eng" }

      it "strips the leading #" do
        expect(client).to receive(:reactions_add).with(name: reaction_name, channel: channel, timestamp: blurb.slack_message_timestamp)
        add_reaction
      end
    end

    context "without a channel" do
      let(:channel) { nil }
      it "doesn't add a reaction" do
        expect(client).not_to receive(:reactions_add)
        add_reaction
      end
    end

    context "without a message timestamp" do
      let!(:blurb) do 
        team.blurbs.create!(
          github_repo: "foo/bar",
          github_id: "1",
          slack_message_timestamp: nil,
        )
      end
      it "doesn't add a reaction" do
        expect(client).not_to receive(:reactions_add)
        add_reaction
      end
    end
  end

  context "#add_message_merge_reaction" do
    let(:reaction_name) { "merged" }
    let(:add_reaction) { SlackNotifier.add_message_merge_reaction(pull_request_blurb: blurb) }
    include_examples "adds a reaction"
  end

  context "#add_message_review_reaction" do
    let(:reaction_name) { "approved" }
    let(:add_reaction) { SlackNotifier.add_message_review_reaction(pull_request_blurb: blurb) }
    include_examples "adds a reaction"
  end

  context "#add_message_requested_changes_reaction" do
    let(:reaction_name) { "requested-changes" }
    let(:add_reaction) { SlackNotifier.add_message_requested_changes_reaction(pull_request_blurb: blurb) }
    include_examples "adds a reaction"
  end
end
