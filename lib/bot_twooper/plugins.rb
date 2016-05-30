require_relative 'plugins/help'
require_relative 'plugins/time'
require_relative 'plugins/events'

module BotTwooper
  module Plugins

    def self.command_for(message)
      if message.body =~ /\A.(\w+)/
        plugins = constants.map { |constant| const_get(constant) }
        result = plugins.find { |plugin| plugin.respond_to?($1) }
        result ? result.method($1) : nil
      end
    end

  end
end