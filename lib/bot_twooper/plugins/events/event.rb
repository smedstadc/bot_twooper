# frozen_string_literal: true

module BotTwooper
  module Plugins
    module Events
      class Event < Sequel::Model
        DAY = 86_400 # seconds
        HOUR = 3600  # ..
        MINUTE = 60  # ..

        dataset_module do
          subset(:recent) { time > ::Time.now - HOUR }
        end

        class << self
          def from_countdown(discord_event)
            event_from_countdown(discord_event) if COUNTDOWN_PATTERN.match?(discord_event.message.content)
          end

          def from_datetime(discord_event)
            event_from_datetime(discord_event) if DATETIME_PATTERN.match?(discord_event.content)
          end

          def event_from_countdown(discord_event)
            logger.debug "creating event from countdown params"
            match = COUNTDOWN_PATTERN.match(discord_event.message.content)

            Event.new do |e|
              e.time = ::Time.now + match[:days].to_i * DAY + match[:hours].to_i * HOUR + match[:minutes].to_i * MINUTE
              e.message = match[:message].strip
              e.room = "#{discord_event.server&.id || 'PERSONAL'}/#{discord_event.channel.id}"
            end
          end

          def event_from_datetime(discord_event)
            logger.debug "creating event from datetime params"
            match = DATETIME_PATTERN.match(discord_event.content)

            Event.new do |e|
              e.time = ::Time.new(match[:year], match[:month], match[:day], match[:hour], match[:minute])
              e.message = match[:message].strip
              e.room = "#{discord_event.server&.id || 'PERSONAL'}/#{discord_event.channel.id}"
            end
          end
        end

        def validate
          super
          errors.add(:room,    "must be present") if room.nil? || room.strip.empty?
          errors.add(:time,    "must be present") if time.nil?
          errors.add(:message, "must be present") if message.nil? || message.strip.empty?
        end

        def to_s
          now          = ::Time.now.to_i
          other        = time.to_i
          delta        = other - now
          delta_string = abbreviate_time_delta(delta)

          if delta.positive?
            "#{delta_string} until #{message} at #{time} (ID: #{id})"
          else
            "#{delta_string} since #{message} at #{time} (ID: #{id})"
          end
        end

        private

        def abbreviate_time_delta(seconds)
          seconds = seconds.abs
          days = seconds / DAY
          hours = seconds % DAY / HOUR
          minutes = seconds % DAY % HOUR / MINUTE
          format("%4.4sd %2.2sh %2.2sm", days, hours, minutes)
        end
      end
    end
  end
end
