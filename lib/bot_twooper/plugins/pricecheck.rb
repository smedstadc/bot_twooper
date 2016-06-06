require_relative 'pricecheck/price_checker'

module BotTwooper
  module Plugins
    module PriceCheck
      USAGE = 'Usage: .jita <item>'

      def self.jita(message)
        if /\A\.\w+ (?<type_name>.+)\z/ =~ message.body
          checker = PriceChecker.new('jita')
          checker.check(type_name)
        else
          USAGE
        end
      end

    end
  end
end
