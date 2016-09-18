#!/usr/bin/env ruby
#coding: utf-8
require 'discordrb'
require 'bot_twooper'

if ARGV.include?("--with-dotenv")
  require 'dotenv'
  Dotenv.load '.env'
end

# noinspection RubyArgCount
bot = Discordrb::Bot.new(token: ENV["DISCORD_BOT_TOKEN"], application_id: ENV["DISCORD_APP_ID"])

puts "This bot's invite URL is #{bot.invite_url}."
puts 'Click on it to invite it to your server.'

module BotTwooper
  class Responder
    def initialize(options={})
      @responder = options[:responder]
    end

    def respond_to(event)
      @responder.respond_to(event)
    end
  end

  class DiscordResponder
    def self.respond_to(event)
      command = BotTwooper::Plugins.command_for(event)
      response = command ? command.call(event) : nil
      unless response.nil? || response.empty?
        if response.is_a? Array
          event << "```\n"
          response[0...10].each do |line|
            event << line
          end
          if response.size > 10
            event << "...and #{response.size - 10} more results, could you be more specific?"
          end
          event << "```"
        elsif response.is_a? String
          event.respond "\n`#{response}`"
        end
      end
    end
  end
end

responder = BotTwooper::Responder.new(responder: BotTwooper::DiscordResponder)
bot.message {|event| responder.respond_to(event)}
bot.run
