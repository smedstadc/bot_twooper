# frozen_string_literal: true

require_relative "sde/updater"

module BotTwooper
  module SDE
    SDE_MD5_URI = "https://www.fuzzwork.co.uk/dump/sqlite-latest.sqlite.bz2.md5"
    SDE_URI = "https://www.fuzzwork.co.uk/dump/sqlite-latest.sqlite.bz2"
    SDE_ARCHIVE_PATH = "db/sqlite-latest.sqlite.bz2"
    SDE_CURRENT_PATH = "db/sqlite-latest.sqlite"

    if Dir[SDE_CURRENT_PATH].empty?
      LOG.warn("Could not load SDE data, you may need to fetch it with 'bot_twooper --update-sde'")
    else
      DB = Sequel.sqlite(SDE::SDE_CURRENT_PATH)
    end
  end
end
