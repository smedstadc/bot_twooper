require_relative 'plugins/help'
require_relative 'plugins/time'
require_relative 'plugins/events'
require_relative 'plugins/pricecheck'

module BotTwooper
  module Plugins

    def self.command_for(event)
      if event.message.content =~ /\A.(\w+)/
        plugins = constants.map { |constant| const_get(constant) }
        result = plugins.find { |plugin| plugin.respond_to?($1) }
        result ? result.method($1) : nil
      end
    end

  end
end
