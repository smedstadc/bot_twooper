module BotTwooper
  module Plugins
    module Events
      class Event < Sequel::Model
        DAY = 86400.freeze  # seconds
        HOUR = 3600.freeze  # ..
        MINUTE = 60.freeze  # ..

        subset(:recent) { time > ::Time.now - HOUR }

        def self.from_countdown(message, options={})
          match = COUNTDOWN_PATTERN.match(message.body)

          if match
            event = Event.new do |event|
              event.time = ::Time.now + match[:days].to_i * DAY + match[:hours].to_i * HOUR + match[:minutes].to_i * MINUTE
              event.message = match[:message].strip
              event.room = options[:global] ? 'global' : message.from.node
            end
          else
            nil
          end
        end


        def self.from_datetime(message, options={})
          match = DATETIME_PATTERN.match(message.body)

          if match
            event = Event.new do |event|
              event.time = ::Time.new(match[:year], match[:month], match[:day], match[:hour], match[:minute])
              event.message = match[:message].strip
              event.room = options[:global] ? 'global' : message.from.node
            end
          else
            nil
          end
        end


        def validate
          super
          errors.add(:room,    'must be present') if room.nil?    || room.strip.empty?
          errors.add(:time,    'must be present') if time.nil?
          errors.add(:message, 'must be present') if message.nil? || message.strip.empty?
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
          '%4.4sd %2.2sh %2.2sm' % [days, hours, minutes]
        end

      end
    end
  end
end