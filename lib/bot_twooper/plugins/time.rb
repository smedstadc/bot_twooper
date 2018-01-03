# frozen_string_literal: true

require "time"

module BotTwooper
  module Plugins
    module Time
      def self.upladtime(_event)
        ::Time.now.iso8601
      end

      def self.time(_event)
        ::Time.now.httpdate
      end
    end
  end
end
