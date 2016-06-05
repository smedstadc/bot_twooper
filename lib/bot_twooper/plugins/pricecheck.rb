require_relative 'pricecheck/helper'

module BotTwooper
  module Plugins
    module PriceCheck
      USAGE = 'Usage: .jita <item>'

      def self.jita(message)
        if /\A\.\w+ (?<type_name>.+)\z/ =~ message.body
          Helper.pricecheck(type_name, 'Jita')
        else
          USAGE
        end
      end

    end
  end
end
