#!/usr/bin/env ruby
# frozen_string_literal: true

require "dotenv"
require "discordrb"
require "bot_twooper"

Dotenv.load ".env"
appid = ENV["DISCORD_APP_ID"]
token = ENV["DISCORD_BOT_TOKEN"]

trap("SIGINT") { exit(130) }
trap("SIGKILL") { exit(1) }
trap("SIGHUP") { exit(1) }

bot = Discordrb::Bot.new token: token, client_id: appid
logger.info "bot-tooper is starting..."
logger.info "This bot's invite URL is #{bot.invite_url}."
puts "Click on it to invite it to your server."

bot.disconnected do |diconnect_event|
  logger.info "disconnect detected, letting process die"
  exit(0)
end

bot.message do |event|
  logger.debug "message received: #{event.message.content.inspect}"
  command = BotTwooper::Plugins.command_for(event)
  response = command ? command.call(event) : nil

  unless response.nil? || response.empty?
    logger.debug "sending response"
    if response.is_a? Array
      event << "```\n"
      response[0...10].each do |line|
        event << line
      end
      event << "...and #{response.size - 10} more lines, could you be more specific?" if response.size > 10
      event << "```"
    elsif response.is_a? String
      event.respond "\n`#{response}`"
    end
  end
end

bot.run
