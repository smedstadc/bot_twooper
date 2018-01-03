# frozen_string_literal: true

require "blather/client/dsl"

module BotTwooper
  class Client
    include Blather::DSL

    def initialize(options = {})
      @rooms = options[:rooms]
      @nick = options[:nick]
      post_init
    end

    def post_init
      when_ready do
        puts "Connected..."
        puts "\n"
        @rooms.each do |room|
          join room, @nick
        end
      end

      subscription :request? do |subscription_request|
        write_to_stream subscription_request.approve!
      end

      message :chat?, :body do |message|
        response = response_for(message)
        say(message.from, response) unless response.nil? || response.blank?
      end

      message :groupchat?, :body do |message|
        response = response_for(message)
        say(message.from.stripped, response, :groupchat) unless response.nil? || response.blank?
      end
    end

    def unbind(reason)
      puts "Connection lost: #{reason}"
      exit(ERROR)
    end

    private

    def response_for(message)
      handle_message(message) unless message.delay || message.from.resource == @nick
    end

    def handle_message(message)
      command = BotTwooper::Plugins.command_for(message)
      response = command ? command.call(message) : nil

      if response.is_a? Array
        ([""] + response).join("\n")
      elsif response.is_a? String
        response
      end
    end
  end
end
