# frozen_string_literal: true

require "sequel"
require "fileutils"

module BotTwooper
  Sequel.extension :migration
  Sequel.default_timezone = :utc

  FileUtils.mkdir_p("db") if Dir["db"].empty?
  DB_PATH = File.expand_path("db/bot_twooper.db")
  DB = Sequel.sqlite(DB_PATH)
  Sequel::Model.db = DB
end
