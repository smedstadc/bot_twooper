require 'time'

module BotTwooper
  module Plugins
    module Time

      def self.upladtime(message)
        ::Time.now.iso8601
      end

      def self.time(message)
        ::Time.now.httpdate
      end

    end
  end
end
