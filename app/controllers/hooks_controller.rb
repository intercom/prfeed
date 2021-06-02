class HooksController < ApplicationController
  before_action :check_hmac

  def check_hmac
    head :bad_request unless github_hmac_valid?
  end

  def github
    blurb = pull_request_blurb
    if blurb.present?
      PullRequestFeed::ExpireCache.run!(blurb: blurb)
      
      SlackNotifier.add_message_merge_reaction(pull_request_blurb: blurb) if merged?
      SlackNotifier.add_message_review_reaction(pull_request_blurb: blurb) if review_approved?
      SlackNotifier.add_message_requested_changes_reaction(pull_request_blurb: blurb) if review_requested_changes?
      SlackNotifier.add_message_comments_added(pull_request_blurb: blurb) if comments_added?
    end

    head :ok
  end

  private def github_hmac_valid?
    hmac_header = request.headers["X-HUB-SIGNATURE"] || ""
    existing_hmac = hmac_header.sub(/sha1=/, "")

    is_valid_hmac = is_valid_hmac?(existing_hmac, request.body.read)
  end

  private def is_valid_hmac?(existing_hmac, data)
    insecure_hmac_sha1 = ::OpenSSL::HMAC.hexdigest('sha1', Rails.application.secrets.github_secret_token, data)
    constant_time_compare_strings(insecure_hmac_sha1, existing_hmac)
  end

  private def constant_time_compare_strings(a, b)
    return false if a == nil || b == nil
    return false if a.bytesize != b.bytesize
    b_bytes = b.unpack('C*')
    cmp = 0
    a.each_byte do |a_byte|
      cmp |= a_byte ^ b_bytes.shift
    end
    cmp == 0
  end

  private def github_repo
    repository_params["full_name"]
  end

  private def pull_request_number
    pull_request_params["number"]
  end

  private def merged?
    action == "closed" && pull_request_params["merged"].to_s == "true"
  end

  private def pull_request_blurb
    PullRequestBlurb.find_by(
      github_repo: github_repo,
      github_id: pull_request_number
    )
  end

  private def pull_request_params
    params.require(:pull_request).permit!
  end

  private def repository_params
    params.require(:repository).permit!
  end

  private def action
    request.request_parameters[:action]
  end

  private def has_review?
    params[:review].present? && action == "submitted"
  end

  private def review_state
    has_review? ? params[:review]["state"].downcase : nil
  end

  private def review_requested_changes?
    has_review? && review_state == "changes_requested"
  end

  private def review_approved?
    has_review? && review_state == "approved"
  end

  private def comments_added?
    has_review? && review_state == "commented"
  end
end
