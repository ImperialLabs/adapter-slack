# frozen_string_literal: true

require 'json'
require 'httparty'

# Slapi Class - Primary Class
# Its main functions are to:
#  1. Configure Slack Client
#     - Iterates over the bot.yml mounted to adapter container
#  2. Contains methods for require route access
#  3. Sends any Messages to SLAPI messages endpoint
class Client
  GREEN = '#229954'
  YELLOW = '#F7DC6F'
  RED = '#A93226'

  def initialize(settings)
    @headers = {}

    # Setup Realtime Client
    Slack.configure do |config|
      config.token = settings.adapter['token']
      raise 'Missing Slack Token configuration!' unless config.token
    end

    @client = Slack::RealTime::Client.new
    @bot_name = @client.self.name
    @bot_id = @client.self.id
    @logger = Logger.new(STDOUT)
    @logger.level = settings.logger_level
  end

  def run
    @client.on :hello do
      @logger.info("Slapi: Successfully connected, welcome '#{@bot_name}' to '#{@client.team.name}'")
    end

    @client.on :message do |data|
      message_stream(data.channel, data.text, data.user) unless data.user == @bot_id
    end
    @client.start_async
  end

  def shutdown
    @client.stop!
  end

  def client_info
    {
      bot: {
        name: @bot_name,
        id: @bot_id
      },
      account: {
        name: @client.team.name
      }
    }.to_json
  end

  def chat_plain(text, channel)
    @client.web_client.chat_postMessage(
      channel: channel,
      as_user: true,
      text: text
    )
  end

  def chat_attachment(channel, attachment)
    @client.web_client.chat_postMessage(
      channel: channel,
      as_user: true,
      attachments: [attachment]
    )
  end

  def chat_emote(text, channel)
    @client.web_client.chat_meMessage(
      channel: channel,
      text: text
    )
  end

  def message_stream(channel, text, user)
    HTTParty.post(
      '/v1/messages',
      body: {
        channel: channel,
        text: text,
        user: user
      },
      headers: @headers
    )
  end
end
