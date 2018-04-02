# frozen_string_literal: true

require 'json'
require 'httparty'
require 'logger'
require 'slack-ruby-client'

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

  def initialize(config, headers = {})
    @headers = headers
    raise 'No token! Please add a slack token to the bot.yml' unless config[:token]
    @client = Slack::RealTime::Client.new(config)
    @logger = Logger.new(STDOUT)
    @logger.level = 'info'
  end

  def run
    @client.on :hello do
      @logger.info("Slack: Successfully connected, welcome '#{@client.self.name}' to '#{@client.team.name}'")
    end

    @client.on :message do |data|
      message_stream(data.channel, data.text, data.user) unless data.user == @client.self.id
    end
    @client.start_async
  end

  def shutdown
    @logger.info("Slack: disconnecting '#{@client.self.name}' from '#{@client.team.name}'")
    @client.stop!
  end

  def client_info
    {
      bot: {
        name: @client.self.name,
        id: @client.self.id
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

  def channel_list
    @client.channels_list.channels
  end

  def channel_info(channel)
    @client.channels_info(channel: channel)
  end

  def user_search(user)
    @client.users_search(user: user)
  end

  def user_info(user)
    @client.users_info(user: user)
  end

  def join(channel)
    @client.channels_join(name: channel)
  end

  def leave(channel)
    @client.channels_leave(name: channel)
  end

  def message_stream(channel, text, user)
    body = {
      channel: channel,
      text: text,
      user: user
    }

    HTTParty.post(
      "http://#{ENV['BOT_URL']}/v1/messages",
      body: body,
      headers: @headers
    )
  end
end
