# frozen_string_literal: true

require "bot_twooper/version"
require "bot_twooper/logging"
require "bot_twooper/db"
require "bot_twooper/sde"
require "bot_twooper/plugins"

def logger
  $logger
end

module BotTwooper
  SUCCESS = 0
  ERROR = 1
end
