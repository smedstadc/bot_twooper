# frozen_string_literal: true

require "open-uri"

module BotTwooper
  module SDE
    class Updater
      def execute
        fetch_sde
        if verify_sde
          extract_sde
          LOG.info("Done.")
          SUCCESS
        else
          ERROR
        end
      rescue StandardError => e
        LOG.error(e)
        ERROR
      end

      private

      def fetch_sde
        LOG.info("Fetching SDE...")
        sde = open(SDE_URI)
        File.copy_stream(sde, SDE_ARCHIVE_PATH)
      end

      def verify_sde
        LOG.info("Verifying SDE...")
        sde_archive = Dir[SDE_ARCHIVE_PATH][0]
        sde_archive_hash = `md5sum #{sde_archive}`.split[0]
        sde_latest_hash = open(SDE_MD5_URI).read.split[0]

        if sde_archive_hash == sde_latest_hash
          LOG.debug("Verify OK ...")
          true
        else
          LOG.error("Verify FAIL...")
          false
        end
      end

      def extract_sde
        LOG.info("Extracting SDE...")
        result = `bunzip2 #{Dir[SDE_ARCHIVE_PATH][0]} --force`
        LOG.debug(result == "" ? "Extract succeeded..." : result)
      end
    end
  end
end
