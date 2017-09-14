require 'net/http'
require 'nokogiri'

module BotTwooper
  module Plugins
    module PriceCheck
      class PriceChecker
        API_ENDPOINT = 'http://api.eve-central.com/api/marketstat'.freeze

        def self.check(event, system)
          if /\A\.\w+ (?<type_name>.+)\z/ =~ event.message.content
            checker = new(system)
            checker.check(type_name)
            checker.messages.sort
          else
            USAGE
          end
        end

        def initialize(system_name = nil)
          @system_name = system_name
          @messages = []
        end


        def check(item_name)
          @search_term = item_name
          fetch_region_id if @system_name
          fetch_system_id if @system_name
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

        def fetch_system_id
          @system_id = SDE::DB[:mapSolarSystems].select(:solarSystemID)
                           .where(solarSystemName: @system_name.capitalize)
                           .first[:solarSystemID]
          puts @system_name
          puts @system_id
        end


        def fetch_type_ids
          @search_term.start_with?('!') ? fetch_single_type : fetch_all_types
        end

        def fetch_single_type
          exact_term = @search_term.gsub('!', '')
          types = SDE::DB[:invTypes]
                      .where(Sequel.ilike(:typeName, "#{exact_term}"))
                      .exclude(Sequel.ilike(:typeName, '%blueprint%'))
                      .exclude(marketGroupID: nil)
                      .exclude(published: 0)
                      .limit(1)

          @type_ids = types.collect {|row| row[:typeID]}
        end

        def fetch_all_types
          types = SDE::DB[:invTypes]
                      .where(Sequel.ilike(:typeName, "%#{@search_term}%"))
                      .exclude(Sequel.ilike(:typeName, '%blueprint%'))
                      .exclude(marketGroupID: nil)
                      .exclude(published: 0)

          @type_ids = types.collect {|row| row[:typeID]}
        end


        def fetch_marketstat
          params = {typeid: @type_ids}
          params.merge!(usesystem: @system_id) if @system_id
          query = URI.encode_www_form(params)
          puts query
          uri = URI(API_ENDPOINT)
          uri.query = query
          @marketstat = Net::HTTP.get(uri)
        rescue SocketError
          @marketstat = "Network error, try again later."
        end


        def format_messages
          xml = Nokogiri::XML(@marketstat)

          if xml.css('marketstat').text.empty? # empty response:  <marketstat></marketstat>
            @messages << "Empty response. Sometimes this happens when your search term matches too many items. (Try '.jita !#{@search_term}' for an exact match.)"
          else
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
          number.to_s.gsub(/(\d)(?=\d{3}+(?:\.|$))(\d{3}\..*)?/, '\1,\2')
        end

      end
    end
  end
end
