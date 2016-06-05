require 'net/http'

module BotTwooper
  module Plugins
    module PriceCheck
      module Helper
        API_ENDPOINT = 'http://api.eve-central.com/api/marketstat'

        @regions = {}
        @types = {}

        # TODO: Filter inappropriate market groups
        # TODO: Filter vague queries
        def self.pricecheck(item, region)
          type_ids = type_ids_for_name(item)
          region_id = region_id_for_system(region)
          marketstat = get_marketstat(type_ids, region_id)

          if marketstat
            format_marketstat(marketstat)
          else
            "No results for search term."
          end
        end

        private
        def self.type_ids_for_name(name)
          SDE::DB[:invTypes].where(Sequel.ilike(:typeName, "%#{name}%")).collect {|row| row[:typeID]}
        end

        def self.type_name_for_id(id)
          @types[:id] || fetch_type_name(id)
        end

        def self.fetch_type_name(id)
          name = SDE::DB[:invTypes][typeID: id][:typeName]
          @types[:id] = name
          name
        end

        def self.region_id_for_system(system_name)
          @regions[system_name] || fetch_region_id(system_name)
        end

        def self.fetch_region_id(system_name)
          region = SDE::DB[:mapDenormalize].select(:regionID).where(Sequel.ilike(:itemName, system_name)).first[:regionID]
          @regions[system_name] = region
          region
        end

        def self.get_marketstat(type_ids, region_id)
          query = URI.encode_www_form(typeid: type_ids, regionlimit: region_id)
          uri = URI(API_ENDPOINT)
          uri.query = query
          Net::HTTP.get(uri)
        end

        def self.format_marketstat(marketstat)
          xml = Nokogiri::XML(marketstat)
          prices = xml.css('type')

          lines = ['']

          prices.each do |row|
            item_name = type_name_for_id(row[:id])
            lowest_sell_price = row.css('sell low').text
            highest_buy_price = row.css('buy high').text
            total_volume = row.css('all volume').text
            lines << "#{item_name} - SELL: #{lowest_sell_price}, BUY: #{highest_buy_price}, VOLUME: #{total_volume}"
          end

          if lines.size > 2
            lines.join("\n")
          else
            lines.join
          end
        end

      end
    end
  end
end
