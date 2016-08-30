require 'time'

module BotTwooper
  module Plugins
    module Time

      def self.upladtime(event)
        ::Time.now.iso8601
      end

      def self.time(event)
        ::Time.now.httpdate
      end

    end
  end
end
