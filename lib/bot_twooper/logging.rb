# frozen_string_literal: true

require "logger"

module BotTwooper
  module Logging
    def self.logger
      @logger ||= Logger.new($stdout)
    end

    def self.logger=(logger)
      @logger = logger
    end
  end

  $logger = Logging.logger
end
