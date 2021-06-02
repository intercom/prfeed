class SlackNotifier

  def self.post_message(channel:, pull_request:, pull_request_blurb:, bump: false)
    return unless channel.present?
    message = compose_message(pull_request: pull_request, bump: bump)

    client = Slack::Web::Client.new
    response = client.chat_postMessage(
      channel: "##{channel}",
      as_user: false,
      username: pull_request.owner,
      icon_url: pull_request.owner_avatar_url,
      text: message
    )

    if response && response["ok"]
      # save the timestamp of the Slack message to allow future reactions to be added
      pull_request_blurb.update(slack_message_timestamp: response["ts"])
    end
  end

  def self.add_message_merge_reaction(pull_request_blurb:)
    add_reaction("merged", pull_request_blurb)
  end

  def self.add_message_review_reaction(pull_request_blurb:)
    add_reaction("approved", pull_request_blurb)
  end

  def self.add_message_requested_changes_reaction(pull_request_blurb:)
    add_reaction("requested-changes", pull_request_blurb)
  end

  def self.add_message_comments_added(pull_request_blurb:)
    add_reaction("commented", pull_request_blurb)
  end

  private_class_method def self.compose_message(pull_request:, bump:)
    message = "#{pull_request.title} `+#{pull_request.line_addition_count} -#{pull_request.line_deletion_count}`: \n" + pull_request.url
    return "*BUMP - this PR is ready for another review* \n" + message if bump
    message
  end

  private_class_method def self.add_reaction(reaction_name, pull_request_blurb)
    team = pull_request_blurb.team
    return unless team.slack_channel && pull_request_blurb.slack_message_timestamp
    slack_channel = "##{team.slack_channel.sub(/^#/, "")}"
    message_timestamp = pull_request_blurb.slack_message_timestamp

    client = Slack::Web::Client.new
    begin
      client.reactions_add(name: reaction_name, channel: slack_channel, timestamp: message_timestamp)
    rescue StandardError => e
      return if e.is_a?(Slack::Web::Api::Errors::SlackError) && e.message == "already_reacted"

      Rails.logger.error("Failed to add reaction, reaction=#{reaction_name} slack_channel=#{slack_channel} message_timestamp=#{message_timestamp} error=#{e.message}")
    end
  end
end