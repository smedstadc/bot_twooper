# frozen_string_literal: true

require_relative "events/event"

module BotTwooper
  module Plugins
    module Events
      COUNTDOWN_PATTERN = /(?<days>\d{1,3})[dD]
                           (?<hours>\d{1,2})[hH]
                           (?<minutes>\d{1,2})[mM]
                           \s
                           (?<message>.+)/x

      DATETIME_PATTERN = /(?<year>\d{4})
                          -
                          (?<month>\d{1,2})
                          -
                          (?<day>\d{1,2})
                          [@Tt]
                          (?<hour>\d{1,2})
                          :
                          (?<minute>\d{1,2})
                          \s
                          (?<message>.+)/x

      ADD_USAGE = "\nUsage: .addop <days>d<hours>h<minutes>m <message>"\
                  "\nUsage: .addop <year>-<month>-<day>@<hour>:<minute> <message>"
      RMOP_PATTERN = /(?<id>\d+)/
      RMOP_USAGE = "\nUsage: .rmop <id>"
      MIGRATIONS_PATH = File.expand_path("../events/migrations", __FILE__).freeze
      Sequel::Migrator.run(DB, MIGRATIONS_PATH, use_transactions: true)

      def self.addop(discord_event)
        logger.debug("processing 'addop' command for #{discord_event}")
        event = Event.from_countdown(discord_event) || Event.from_datetime(discord_event)
        if event&.valid?
          event.save
          "Event added."
        else
          ADD_USAGE
        end
      end

      def self.ops(discord_event)
        logger.debug("processing 'ops' command for #{discord_event}")
        room = "#{discord_event.server&.id || 'PERSONAL'}/#{discord_event.channel.id}"
        room_events = Event.recent.where(room: room).order(:time)

        response_lines = ["### Ops for this room ###"]
        response_lines << "Empty..." if room_events.count.zero?
        room_events.each do |event|
          response_lines << event.to_s
        end

        response_lines.compact
      end

      def self.rmop(discord_event)
        logger.debug("processing 'rmop' command for #{discord_event}")
        room = "#{discord_event.server&.id || 'PERSONAL'}/#{discord_event.channel.id}"
        match = RMOP_PATTERN.match(discord_event.message.content)
        if match
          logger.debug "attempting to remove event with id #{match[:id]}"
          event = Event.find(id: match[:id], room: room)
          if event
            event.delete
            "Removed: #{event.message}"
          else
            "Sorry, I can't do that."
          end
        else
          logger.debug "bad command pattern"
          RMOP_USAGE
        end
      end
    end
  end
end
