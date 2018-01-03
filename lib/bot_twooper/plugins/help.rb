# frozen_string_literal: true

module BotTwooper
  module Plugins
    module Help
      def self.help(_discordevent)
        commands = Plugins.constants.map { |c| Plugins.const_get(c).methods(false) }
        commands = commands.flatten.map { |c| ".#{c}" }
        "Available commands: #{commands.join(', ')}"
      end
    end
  end
end
