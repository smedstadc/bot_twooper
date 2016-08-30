require_relative 'pricecheck/price_checker'

module BotTwooper
  module Plugins
    module PriceCheck
      USAGE = 'Usage: .jita <item>'

      def self.jita(event)
        PriceChecker.check(event, 'jita')
      end

      def self.amarr(event)
        PriceChecker.check(event, 'amarr')
      end

      def self.dodixie(event)
        PriceChecker.check(event, 'dodixie')
      end

      def self.rens(event)
        PriceChecker.check(event, 'rens')
      end

      def self.hek(event)
        PriceChecker.check(event, 'hek')
      end

    end
  end
end
