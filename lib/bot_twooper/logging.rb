require 'logger'

module BotTwooper
  module Logging
    def self.logger
      @logger ||= Logger.new($stdout)
    end

    def self.logger=(logger)
      @logger = logger
    end
  end

  LOG = Logging.logger
end