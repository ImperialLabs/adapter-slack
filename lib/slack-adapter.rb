# frozen_string_literal: true

require 'json'
require 'httparty'
require 'sinatra'
require 'sinatra/base'
require 'sinatra/config_file'

# Slapi Class - Primary Class
# Its main functions are to:
#  1. Set Sinatra Environment/Config
#     - configs loaded from ./config folder
#  2. Contains Required Endpoints for SLAPI
class SlackAdapter < Sinatra::Base
  set :root, File.dirname(__FILE__)
  register Sinatra::ConfigFile

  Dir[File.dirname(__FILE__) + '/**/*.rb'].each { |file| require file }

  configure :production, :test, :development do
    enable :logging
  end

  config_file 'environments.yml'

  config_file 'bot.yml' if File.file?('./bot.yml')
  raise 'No config found! Please attach bot.yml to adapter container' unless File.file?('./bot.yml')

  @headers = {}

  @logger = Logger.new(STDOUT)
  @logger.level = settings.logger_level

  @client = Client.new(settings)

  post '/join' do
    raise 'missing channel' unless params[:channel]
    @client.channels_join(name: channel)
  end

  post '/part' do
    raise 'missing channel' unless params[:channel]
    @client.channels_leave(name: channel)
  end

  post '/users' do
    raise 'missing type of user action' unless params[:type]
    raise 'missing user' unless params[:user]
    case params[:type]
    when params[:type].casecmp('search')
      @client.users_search(user: params[:user])
    when params[:type].casecmp('info')
      @client.users_info(user: params[:user])
    end
  end

  post '/messages' do
    raise 'missing type of message' unless params[:type]
    raise 'missing channel' unless params[:channel]
    case params[:type]
    when params[:type].casecmp('plain')
      @client.chat_plain(params[:text], params[:channel])
    when params[:type].casecmp('emote')
      @client.chat_emote(params[:text], params[:channel])
    when params[:type].casecmp('formatted')
      @client.chat_attachment(params[:attachment], params[:channel])
    end
  end

  post '/rooms' do
    raise 'missing type of user action' unless params[:type]
    case params[:type]
    when params[:type].casecmp('list')
      @client.channels_list.channels
    when params[:type].casecmp('info')
      raise 'missing channel' unless params[:channel]
      @client.channels_info(channel: params[:channel])
  end

  post '/run' do
    @client.run
  end

  post 'shutdown' do
    @client.shutdown
  end
end
