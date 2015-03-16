module Krikri::Harvesters
  ##
  # A harvester implementation for REST APIs
  class ApiHarvester
    include Krikri::Harvester

    attr_reader :opts

    ##
    # @param opts [Hash] options for the harvester
    # @see .expected_opts
    def initialize(opts = {})
      super
      @opts = opts.fetch(:api, {})
    end

    ##
    # @return [Hash] A hash documenting the allowable options to pass to
    #   initializers.
    #
    # @see Krikri::Harvester::expected_opts
    def self.expected_opts
      {
        key: :api,
        opts: {
          params: { type: :string, required: false }
        }
      }
    end

    ##
    # @see Krikri::Harvester#count
    def count
      request(opts)['response']['numFound']
    end

    ##
    # @return [Enumerator::Lazy] an enumerator of the records targeted by this
    #   harvester.
    def records
      enumerate_records.lazy.map { |rec| build_record(rec) }
    end

    ##
    # Gets a single record with the given identifier from the API
    #
    # @return [Enumerator::Lazy] an enumerator over the ids for the records
    #   targeted by this harvester.
    def record_ids
      enumerate_records.lazy.map { |r| r['record_id'] }
    end

    ##
    # @param identifier [#to_s] the identifier of the record to get
    # @return [#to_s] the record
    def get_record(identifier)
      response = request(:params => { :q => "id:#{identifier.to_s}" })
      build_record(response['response']['docs'].first)
    end

    private

    ##
    # Send a request via `RestClient`, and parse the result as JSON
    def request(request_opts)
      JSON.parse(RestClient.get(uri, request_opts))
    end

    ##
    # Given a current set of options and a number of records from the last
    # request, generate the options for the next request.
    #
    # @param opts [Hash] an options hash from the previous request
    # @param record_count [#to_i]
    #
    # @return [Hash] the next request's options hash
    def next_options(opts, record_count)
      old_start = opts['params'].fetch('start', 0)
      opts['params']['start'] = old_start.to_i + record_count
      opts
    end

    ##
    # @return [Enumerator] an enumerator over the records
    def enumerate_records
      Enumerator.new do |yielder|
        request_opts = opts.deep_dup
        loop do
          break if request_opts.nil?
          docs = request(request_opts.dup)['response']['docs']
          break if docs.empty?

          docs.each { |r| yielder << r }

          request_opts = next_options(request_opts, docs.count)
        end
      end
    end

    ##
    # Builds an instance of `@record_class` with the given doc's JSON as
    # content.
    #
    # @param doc [#to_json] the content to serialize as JSON in `#content`
    # @return [#to_s] an instance of @record_class with a minted id and
    #   content the given content
    def build_record(doc)
      @record_class.build(mint_id(doc['record_id']), doc.to_json)
    end
  end
end
