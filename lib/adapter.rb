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

  set :json_content_type, :js

  configure :production, :test, :development do
    enable :logging
  end

  headers = ENV['HEADERS'] ? eval(ENV['HEADERS']) : {}
  @@slack = Client.new(settings.adapter['config'], headers)
  @@slack.run

  get '/info' do
    begin
      response = @@slack.client_info
      body response
      status 200
    rescue => e
      status 500
      body "[ERROR] - Received #{e}"
    end
  end

  post '/join' do
    raise 'missing channel' unless params[:channel]
    begin
      response = @@slack.join(params[:channel])
      body response.to_s
      status 200
    rescue => e
      status 500
      body "[ERROR] - Received #{e}"
    end
  end

  post '/part' do
    raise 'missing channel' unless params[:channel]
    begin
      response = @@slack.leave(params[:channel])
      body response.to_s
      status 200
    rescue => e
      status 500
      body "[ERROR] - Received #{e}"
    end
  end

  post '/users' do
    raise 'missing type of user action' unless params[:type]
    raise 'missing user' unless params[:user]
    case params[:type]
    when params[:type].casecmp('search')
      begin
        response = @@slack.user_search(params[:user])
        body response.to_s
        status 200
      rescue => e
        status 500
        body "[ERROR] - Received #{e}"
      end
    when params[:type].casecmp('info')
      begin
        response = @@slack.user_info(params[:user])
        body response.to_s
        status 200
      rescue => e
        status 500
        body "[ERROR] - Received #{e}"
      end
    end
  end

  post '/messages' do
    raise 'missing type of message' unless params[:type]
    raise 'missing channel' unless params[:channel]
    if params[:type].include?('plain')
      begin
        response = @@slack.chat_plain(params[:text], params[:channel])
        body response.to_s
        status 200
      rescue => e
        status 500
        body "[ERROR] - Received #{e}"
      end
    elsif params[:type].include?('emote')
      begin
        response = @@slack.chat_emote(params[:text], params[:channel])
        body response.to_s
        status 200
      rescue => e
        status 500
        body "[ERROR] - Received #{e}"
      end
    elsif params[:type].include?('formatted')
      begin
        response = @@slack.chat_attachment(params[:channel], params[:attachment])
        body response.to_s
        status 200
      rescue => e
        status 500
        body "[ERROR] - Received #{e}"
      end
    end
  end

  post '/rooms' do
    raise 'missing type of user action' unless params[:type]
    case params[:type]
    when params[:type].casecmp('list')
      begin
        response = @@slack.channel_list
        body response.to_s
        status 200
      rescue => e
        status 500
        body "[ERROR] - Received #{e}"
      end
    when params[:type].casecmp('info')
      raise 'missing channel' unless params[:channel]
      begin
        response = @@slack.channel_info(params[:channel])
        body response.to_s
        status 200
      rescue => e
        status 500
        body "[ERROR] - Received #{e}"
      end
    end
  end

  get '/shutdown' do
    begin
      @@slack.shutdown
      status 200
    rescue => e
      status 500
      body "[ERROR] - Received #{e}"
    end
  end
end
