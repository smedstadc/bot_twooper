#!/usr/bin/env ruby
#coding: utf-8
require 'dotenv'
require 'discordrb'
require 'bot_twooper'

Dotenv.load '.env'
appid = ENV["DISCORD_APP_ID"]
token = ENV["DISCORD_BOT_TOKEN"]

bot = Discordrb::Bot.new token: token, application_id: appid

bot.message(in: 't-s-k') do |event|
  command = BotTwooper::Plugins.command_for(event)
  response = command ? command.call(event) : nil
  unless response.nil? || response.empty?
    if response.is_a? Array
      response.each do |line|
        event << line
      end
    elsif response.is_a? String
      event.respond response unless response.blank?
    end
  end
end

bot.run