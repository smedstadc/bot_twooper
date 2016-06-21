require_relative 'pricecheck/price_checker'

module BotTwooper
  module Plugins
    module PriceCheck
      USAGE = 'Usage: .jita <item>'

      def self.jita(message)
        PriceChecker.check(message, 'jita')
      end

      def self.amarr(message)
        PriceChecker.check(message, 'amarr')
      end

      def self.dodixie(message)
        PriceChecker.check(message, 'dodixie')
      end

      def self.rens(message)
        PriceChecker.check(message, 'rens')
      end

      def self.hek(message)
        PriceChecker.check(message, 'hek')
      end

    end
  end
end
