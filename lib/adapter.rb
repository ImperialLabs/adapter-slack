# frozen_string_literal: true

require 'json'
require 'httparty'
require 'logger'
require 'sinatra'
require 'sinatra/base'
require 'sinatra/config_file'
require_relative 'adapter/client'

# Slapi Class - Primary Class
# Its main functions are to:
#  1. Set Sinatra Environment/Config
#     - configs loaded from ./config folder
#  2. Contains Required Endpoints for SLAPI
class Adapter < Sinatra::Base
  set :root, File.dirname(__FILE__)
  register Sinatra::ConfigFile

  config_file '../environments.yml'
  config_file '../bot.yml'

  configure :production, :test, :development do
    enable :logging
  end

  @headers = {}

  @logger = Logger.new(STDOUT)
  @logger.level = 'info'
  @slack = Client.new(settings.adapter['config'])

  get '/info' do
    begin
      body @slack.client_info
      status 200
    rescue => e
      status 500
      body "[ERROR] - Received #{e}"
      @logger.error("[ERROR] - Received #{e}")
    end
  end

  post '/join' do
    raise 'missing channel' unless params[:channel]
    begin
      body @slack.join(params[:channel])
      status 200
    rescue => e
      status 500
      body "[ERROR] - Received #{e}"
      @logger.error("[ERROR] - Received #{e}")
    end
  end

  post '/part' do
    raise 'missing channel' unless params[:channel]
    begin
      body @slack.leave(params[:channel])
      status 200
    rescue => e
      status 500
      body "[ERROR] - Received #{e}"
      @logger.error("[ERROR] - Received #{e}")
    end
  end

  post '/users' do
    raise 'missing type of user action' unless params[:type]
    raise 'missing user' unless params[:user]
    case params[:type]
    when params[:type].casecmp('search')
      begin
        body @slack.user_search(params[:user])
        status 200
      rescue => e
        status 500
        body "[ERROR] - Received #{e}"
        @logger.error("[ERROR] - Received #{e}")
      end
    when params[:type].casecmp('info')
      begin
        body @slack.user_info(params[:user])
        status 200
      rescue => e
        status 500
        body "[ERROR] - Received #{e}"
        @logger.error("[ERROR] - Received #{e}")
      end
    end
  end

  post '/messages' do
    raise 'missing type of message' unless params[:type]
    raise 'missing channel' unless params[:channel]
    case params[:type]
    when params[:type].casecmp('plain')
      begin
        body @slack.chat_plain(params[:text], params[:channel])
        status 200
      rescue => e
        status 500
        body "[ERROR] - Received #{e}"
        @logger.error("[ERROR] - Received #{e}")
      end
    when params[:type].casecmp('emote')
      begin
        body @slack.chat_emote(params[:text], params[:channel])
        status 200
      rescue => e
        status 500
        body "[ERROR] - Received #{e}"
        @logger.error("[ERROR] - Received #{e}")
      end
    when params[:type].casecmp('formatted')
      begin
        body @slack.chat_attachment(params[:attachment], params[:channel])
        status 200
      rescue => e
        status 500
        body "[ERROR] - Received #{e}"
        @logger.error("[ERROR] - Received #{e}")
      end
    end
  end

  post '/rooms' do
    raise 'missing type of user action' unless params[:type]
    case params[:type]
    when params[:type].casecmp('list')
      begin
        body @slack.channel_list
        status 200
      rescue => e
        status 500
        body "[ERROR] - Received #{e}"
        @logger.error("[ERROR] - Received #{e}")
      end
    when params[:type].casecmp('info')
      raise 'missing channel' unless params[:channel]
      begin
        body @slack.channel_info(params[:channel])
        status 200
      rescue => e
        status 500
        body "[ERROR] - Received #{e}"
        @logger.error("[ERROR] - Received #{e}")
      end
    end
  end

  post '/run' do
    begin
      @slack.run
      status 200
    rescue => e
      status 500
      body "[ERROR] - Received #{e}"
      @logger.error("[ERROR] - Received #{e}")
    end
  end

  post 'shutdown' do
    begin
      @slack.shutdown
      status 200
    rescue => e
      status 500
      body "[ERROR] - Received #{e}"
      @logger.error("[ERROR] - Received #{e}")
    end
  end
end
