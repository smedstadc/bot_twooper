require 'open-uri'

module BotTwooper
  module SDE
    class Updater
      include Logging

      def execute
        fetch_sde
        if verify_sde
          extract_sde
          logger.info("Done.")
          SUCCESS
        else
          ERROR
        end
      rescue Exception => e
        logger.error(e)
        ERROR
      end

      private
      def fetch_sde
        logger.info("Fetching SDE...")
        sde = open(SDE_URI)
        File.copy_stream(sde, SDE_ARCHIVE_PATH)
      end

      def verify_sde
        logger.info("Verifying SDE...")
        sde_archive = Dir[SDE_ARCHIVE_PATH][0]
        sde_archive_hash = `md5sum #{sde_archive}`.split[0]
        sde_latest_hash = open(SDE_MD5_URI).read.split[0]

        if sde_archive_hash == sde_latest_hash
          logger.error("Verify OK ...")
          true
        else
          logger.error("Verify FAIL...")
          false
        end
      end

      def extract_sde
        logger.info("Extracting SDE...")
        result = `bunzip2 #{Dir[SDE_ARCHIVE_PATH][0]} --force`
        logger.debug(result == "" ? "Extract succeeded..." : result)
      end
    end
  end
end
