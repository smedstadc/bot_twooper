require_relative 'events/event'

module BotTwooper
  module Plugins
    module Events
      COUNTDOWN_PATTERN = /(?<days>\d{1,3})[dD](?<hours>\d{1,2})[hH](?<minutes>\d{1,2})[mM] (?<message>.+)/.freeze
      DATETIME_PATTERN = /(?<year>\d{4})-(?<month>\d{1,2})-(?<day>\d{1,2})[@Tt](?<hour>\d{1,2}):(?<minute>\d{1,2}) (?<message>.+)/.freeze
      ADD_USAGE = "\nUsage: .addop <days>d<hours>h<minutes>m <message>\nUsage: .addop <year>-<month>-<day>@<hour>:<minute> <message>".freeze
      RMOP_PATTERN = /(?<id>\d+)/.freeze
      RMOP_USAGE = "\nUsage: .rmop <id>".freeze
      MIGRATIONS_PATH = File.expand_path('../events/migrations', __FILE__).freeze
      Sequel::Migrator.run(DB, MIGRATIONS_PATH, :use_transactions=>true)


      def self.addop(discordevent)
        event = Event.from_countdown(discordevent) || Event.from_datetime(discordevent)
        if event&.valid?
          event.save
          "Event added."
        else
          ADD_USAGE
        end
      end

      def self.ops(discordevent)
        room = "#{discordevent.server&.id || "PERSONAL"}/#{discordevent.channel.id}"
        room_events = Event.recent.where(room: room).order(:time)

        response_lines = ["### Ops for this room ###"]
        response_lines << "Empty..." if room_events.count == 0
        room_events.each do |event|
          response_lines << event.to_s
        end

        response_lines.compact
      end


      def self.rmop(discordevent)
        room = "#{discordevent.server&.id || "PERSONAL"}/#{discordevent.channel.id}"
        match = RMOP_PATTERN.match(discordevent.message.content)
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
      end

    end
  end
end
