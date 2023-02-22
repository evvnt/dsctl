require 'logger'

module Dsctl
  module Helpers
    module Logger
      def logger
        Logger.logger
      end

      def self.logger
        @logger ||= initiate_logger
      end

      def self.initiate_logger
        logger = ::Logger.new(STDOUT)
        logger.level = ENV['DEBUG_MODE'] == 'true' ? ::Logger::DEBUG : ::Logger::INFO
        logger.formatter = proc do |severity, datetime, progname, msg|
          "#{severity}: #{msg}\n"
        end
        logger
      end
    end
  end
end
