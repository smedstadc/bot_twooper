require 'net/http'
require 'nokogiri'

module BotTwooper
  module Plugins
    module PriceCheck
      class PriceChecker
        API_ENDPOINT = 'http://api.eve-central.com/api/marketstat'

        def initialize(system_name = nil)
          @system_name = system_name
          @messages = []
        end


        def check(item_name)
          @search_term = item_name
          fetch_region_id if @system_name
          fetch_type_ids
          fetch_marketstat
          format_messages
        end

        def messages
          @messages
        end


        private
        def fetch_region_id
          @region_id = SDE::DB[:mapDenormalize].select(:regionID)
            .where(Sequel.ilike(:itemName, @system_name))
            .first[:regionID]
        end


        def fetch_type_ids
          types = SDE::DB[:invTypes]
            .where(Sequel.ilike(:typeName, "%#{@search_term}%"))
            .exclude(Sequel.ilike(:typeName, '%blueprint%'))
            .exclude(marketGroupID: nil)
            .exclude(published: 0)

          @type_ids = types.collect {|row| row[:typeID]}
        end


        def fetch_marketstat
          params = {typeid: @type_ids}
          params.merge!(regionlimit: @region_id) if @region_id
          query = URI.encode_www_form(params)
          uri = URI(API_ENDPOINT)
          uri.query = query
          @marketstat = Net::HTTP.get(uri)
        end


        def format_messages
          if @marketstat
            xml = Nokogiri::XML(@marketstat)
            types = xml.css('type')

            types.each do |type|
              @messages << price_message_for_type(type)
            end
          end
        end


        def price_message_for_type(type)
          item_name = type_name_for_id(type[:id])
          min_sell = number_with_commas(type.css('sell min').text)
          max_buy = number_with_commas(type.css('buy max').text)
          volume = number_with_commas(type.css('all volume').text)

          "#{item_name} - sell: #{min_sell}, buy: #{max_buy}, volume: #{volume}"
        end


        def type_name_for_id(id)
          SDE::DB[:invTypes][typeID: id][:typeName]
        end


        def number_with_commas(number)
          number.to_s.gsub(/(\d)(?=\d{3}+(?:\.|$))(\d{3}\..*)?/,'\1,\2')
        end

      end
    end
  end
end
