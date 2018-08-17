# frozen_string_literal: true

require_relative "plugins/help"
require_relative "plugins/time"
require_relative "plugins/events"
require_relative "plugins/pricecheck"

module BotTwooper
  module Plugins
    def self.command_for(event)
      find_command_handler(Regexp.last_match(1)) if event.message.content =~ /\A\.(\w+)/
    end

    def self.find_command_handler(command_string)
      logger.debug "finding command for #{command_string}"
      plugins = constants.map { |constant| const_get(constant) }
      result = plugins.find { |plugin| plugin.respond_to?(command_string) }
      command_handler = result ? result.method(command_string) : nil
      logger.debug "found command handler: #{command_handler}"
      return command_handler
    end
  end
end
