require_relative 'events/event'

module BotTwooper
  module Plugins
    module Events
      COUNTDOWN_PATTERN = /(?<days>\d{1,3})[dD](?<hours>\d{1,2})[hH](?<minutes>\d{1,2})[mM] (?<message>.+)/.freeze
      DATETIME_PATTERN = /(?<year>\d{4})-(?<month>\d{1,2})-(?<day>\d{1,2})[@Tt](?<hour>\d{1,2}):(?<minute>\d{1,2}) (?<message>.+)/.freeze
      ADD_USAGE = "\nUsage: .addop <days>d<hours>h<minutes>m <message>\nUsage: .addop <year>-<month>-<day>@<hour>:<minute> <message>".freeze
      GLOBAL_ADD_USAGE = "\nUsage: .addgop <days>d<hours>h<minutes>m <message>\nUsage: .addgop <year>-<month>-<day>@<hour>:<minute> <message>".freeze
      RMOP_PATTERN = /(?<id>\d+)/.freeze
      RMOP_USAGE = "\nUsage: .rmop <id>".freeze
      RMGOP_USAGE = "\nUsage: .rmgop <id>".freeze
      MIGRATIONS_PATH = File.expand_path('../events/migrations', __FILE__).freeze
      Sequel::Migrator.run(DB, MIGRATIONS_PATH, :use_transactions=>true)


      def self.addop(message)
        if message.groupchat?
          event = Event.from_countdown(message) || Event.from_datetime(message)
          if event&.valid?
            event.save
            "Event added."
          else
            ADD_USAGE
          end
        else
          "You need to do that in a room with me."
        end
      end


      def self.addgop(message)
        event = Event.from_countdown(message, global: true) || Event.from_datetime(message, global: true)
        if event&.valid?
          event.save
          "Event added."
        else
          GLOBAL_ADD_USAGE
        end
      end


      def self.ops(message)
        global_events = Event.recent.where(room: 'global').order(:time)

        response_lines = ["", "### GLOBAL ###"]
        response_lines << "Empty..." if global_events.count == 0
        global_events.each do |event|
          response_lines << event.to_s
        end

        if message.groupchat?
          room = message.from.node
          room_events = Event.recent.where(room: room).order(:time)

          response_lines += ["", "### #{room.upcase} ###"]
          response_lines << "Empty..." if room_events.count == 0
          room_events.each do |event|
            response_lines << event.to_s
          end
        end

        response_lines.compact.join("\n")
      end


      def self.rmop(message)
        if message.groupchat?
          room = message.from.node
          match = RMOP_PATTERN.match(message.body)
          if match
            event = Event.find(id: match[:id], room: room)
            if event
              event.delete
              "Removed: #{event.message}"
            else
              "Sorry, I can't do that."
            end
          else
            RMOP_USAGE
          end
        else
          "You need to do that in a room with me."
        end
      end


      def self.rmgop(message)
        match = RMOP_PATTERN.match(message.body)
        if match
          event = Event.find(id: match[:id], room: 'global')
          if event
            event.delete
            "Removed: #{event.message}"
          else
            "Sorry, I can't do that."
          end
        else
          RMGOP_USAGE
        end
      end

    end
  end
end
