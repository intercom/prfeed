require "rails_helper"

RSpec.describe HooksController, :type => :controller do

  def hmac_signature(data)
    secret = Rails.application.secrets.github_secret_token
    ::OpenSSL::HMAC.hexdigest('sha1', secret, data)
  end

  context "with hmac signing" do
    let(:post_params) { {repository: {full_name: "foo/bar"}, pull_request: {number: 1}} }
    let(:headers) { {"X-HUB-SIGNATURE" => hmac_signature(post_params.to_query)} }

    before do
      request.headers.merge!(headers)
    end

    it "should fail a bad hmac" do
      request.headers.merge!({"X-HUB-SIGNATURE" => "BAD_SIGNATURE"})
      post :github, params: post_params
      expect(response.status).to eq(400)
    end

    it "should succeed" do
      post :github, params: post_params
      expect(response.status).to eq(200)
    end

    context "with a pull request" do
      let(:client) { double("::Slack::Web::Client") }
      let(:webhook_action) { "closed" }
      let(:merged) { true }
      let(:post_params) do
        {
          action: webhook_action,
          repository: {
            full_name: "foo/bar"
          }, 
          pull_request: {
            number: 1,
            merged: merged
          }
        }
      end
      let(:team) { Team.create(name: "bar") }
      let!(:blurb) do 
        team.blurbs.create!(
          github_repo: "foo/bar",
          github_id: "1"
        )
      end

      before do
        allow(Slack::Web::Client).to receive(:new).and_return(client)
        allow(client).to receive(:chat_postMessage)
        allow(client).to receive(:reactions_add)
      end

      it "expires the cache" do
        expect(PullRequestFeed::ExpireCache).to receive(:run!).once
        post :github, params: post_params
        expect(response.status).to eq(200)
      end

      it "adds a merge reaction" do
        expect(SlackNotifier).to receive(:add_message_merge_reaction).with(pull_request_blurb: blurb)
        expect(SlackNotifier).to_not receive(:add_message_review_reaction)
        expect(SlackNotifier).to_not receive(:add_message_requested_changes_reaction)
        post :github, params: post_params
        expect(response.status).to eq(200)
      end

      context "with a closed unmerged PR" do
        let(:merged) { false }

        it "adds no reactions" do
          expect(SlackNotifier).to_not receive(:add_message_merge_reaction)
          expect(SlackNotifier).to_not receive(:add_message_review_reaction)
          expect(SlackNotifier).to_not receive(:add_message_requested_changes_reaction)
          post :github, params: post_params
          expect(response.status).to eq(200)
        end
      end

      context "with an approved review" do
        let(:post_params) do
          {
            action: "submitted",
            repository: {
              full_name: "foo/bar"
            }, 
            pull_request: {
              number: 1,
              merged: nil
            },
            review: {
              id: 123,
              state: "approved"
            }
          }
        end

        it "adds a reviewed reaction" do
          expect(SlackNotifier).to_not receive(:add_message_merge_reaction)
          expect(SlackNotifier).to receive(:add_message_review_reaction).with(pull_request_blurb: blurb)
          expect(SlackNotifier).to_not receive(:add_message_requested_changes_reaction)
          post :github, params: post_params
          expect(response.status).to eq(200)
        end
      end

      context "with a requested changes review" do
        let(:post_params) do
          {
            action: "submitted",
            repository: {
              full_name: "foo/bar"
            }, 
            pull_request: {
              number: 1,
              merged: nil
            },
            review: {
              id: 123,
              state: "changes_requested"
            }
          }
        end

        it "adds a requested changes reaction" do
          expect(SlackNotifier).to_not receive(:add_message_merge_reaction)
          expect(SlackNotifier).to_not receive(:add_message_review_reaction)
          expect(SlackNotifier).to receive(:add_message_requested_changes_reaction).with(pull_request_blurb: blurb)
          post :github, params: post_params
          expect(response.status).to eq(200)
        end
      end
    end
  end
end
