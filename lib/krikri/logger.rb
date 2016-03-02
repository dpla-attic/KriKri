module Krikri
  ##
  # An application-wide tagged logger
  # 
  # @example with default logger
  #   Krikri::Logger.log :info, 'message'
  #
  # @example with custom logger
  #   logger = Logger.new(my_logger)
  #   logger.log :info, 'message'
  class Logger
    ##
    # @param [ActiveSupport::TaggedLogging] logger
    def initialize(logger = ActiveSupport::TaggedLogging.new(Rails.logger))
      @logger = logger
    end

    class << self
      ##
      # Initializes a logger with the default settings and logs a message to it
      # @see #log
      def log(priority, msg)
        new.log(priority, msg)
      end
    end

    ##
    # Log a message, tagged for application-wide consistency
    #
    # @param [Symbol] priority  a priority tag
    # @param [string] msg  the message to log
    def log(priority, msg)
      @logger.tagged(Time.now.to_s, Process.pid, 'Krikri') do
        @logger.send(priority, msg)
      end
    end
  end
end
