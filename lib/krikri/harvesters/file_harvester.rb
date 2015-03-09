module Krikri::Harvesters
  ##
  # A harvester implementation for streaming files
  class FileHarvester
    include Krikri::Harvester

    ##
    # @see #expected_opts
    def record_ids(opts = {})
      [].to_enum.lazy
    end

    def records(opts = {})
      [].to_enum.lazy
    end

    ##
    # Gets a single record with the given identifier from the file
    #
    # @param identifier [#to_s] the identifier of the record to get
    # @param opts [Hash] options to pass to the OAI client
    def get_record(identifier, opts = {})
    end

    ##
    # @see Krikri::Harvester::expected_opts
    def self.expected_opts
      {
        key: :file,
        opts: { }
      }
    end
  end
end
