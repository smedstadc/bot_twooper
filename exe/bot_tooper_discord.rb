#!/usr/bin/env ruby
# frozen_string_literal: true

require "dotenv"
require "discordrb"
require "bot_twooper"

Dotenv.load ".env"
appid = ENV["DISCORD_APP_ID"]
token = ENV["DISCORD_BOT_TOKEN"]

bot = Discordrb::Bot.new token: token, client_id: appid

puts "This bot's invite URL is #{bot.invite_url}."
puts "Click on it to invite it to your server."

bot.message do |event|
  command = BotTwooper::Plugins.command_for(event)
  response = command ? command.call(event) : nil

  unless response.nil? || response.empty?
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
