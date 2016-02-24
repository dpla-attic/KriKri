module Krikri::Harvesters
  ##
  # A harvester implementation for OAI-PMH
  #
  # Accepts options to pass to OAI client as `:oai => opts`
  #
  # @example
  #
  #   OAIHarvester.new(:uri => endpoint,
  #     :oai => { :set => 'my_set', :metadata_prefix => 'oai_dc' }
  #
  # Options allowed are:
  #
  #   - set: A string or array of strings specifying the sets to harvest.
  #          If multiple sets are given, they will be lazily requested from
  #          `OAI::Client#list_records` in turn and combined into a single
  #          enumerator.
  #   - skip_set: A string or array of strings specifying the sets to skip.
  #               If both `set` and `skip_set` are given, sets specified as
  #               skip are excluded from the harvest. Otherwise, all sets
  #               returned by `#set` except those skipped will be harvested.
  #   - metadata_prefix: A string specifying the metadata prefix. e.g. 'oai_dc'.
  #   - from: The begin date for the harvest.
  #   - until: The end date for the harvest.
  #   - id_path: An alternate xpath (e.g. '//dc:identifier') from which to load
  #              raw identifier strings. Default:  <record><header><identifier>.
  #
  # @see http://www.rubydoc.info/gems/oai/OAI/Client
  class OAIHarvester
    include Krikri::Harvester
    attr_accessor :client

    ##
    # @param opts [Hash] options to pass through to client requests.
    #   Allowable options are specified in OAI::Const::Verbs. Currently :from,
    #   :until, :set, and :metadata_prefix.
    #   Additionally, you may pass an xpath string to `:id_path` specifying the
    #   location of the IDs.
    # @see OAI::Client
    # @see #expected_opts
    def initialize(opts = {})
      opts[:harvest_behavior] ||= OAISkipDeletedBehavior
      super

      @opts    = opts.fetch(:oai, {})
      @id_path = @opts.delete(:id_path) { false }

      http_conn = Faraday.new do |conn|
        conn.request :retry, :max => 3
        conn.response :follow_redirects, :limit => 5
        conn.response :logger, Rails.logger
        conn.adapter :net_http
      end

      @client = OAI::Client.new(uri, :http => http_conn)
    end

    ##
    # Sends ListIdentifier requests lazily.
    #
    # The following will only send requests to the endpoint until it
    # has 1000 record ids:
    #
    #     record_ids.take(1000)
    #
    # @param opts [Hash] opts to pass to OAI::Client
    # @see #expected_opts
    def record_ids(opts = {})
      opts = @opts.merge(opts)
      request_with_sets(opts) do |set_opts|
        client.list_identifiers(set_opts).full.lazy.flat_map(&:identifier)
      end
    end

    # Count on record_ids will request all ids and load them into memory
    # TODO: an efficient implementation of count for OAI
    def count
      raise NotImplementedError
    end

    ##
    # Sends ListRecords requests lazily.
    #
    # The following will only send requests to the endpoint until it
    # has 1000 records:
    #
    #     records.take(1000)
    #
    # @param opts [Hash] opts to pass to OAI::Client
    # @see #expected_opts
    def records(opts = {})
      opts = @opts.merge(opts)
      request_with_sets(opts) do |set_opts|
        client.list_records(set_opts).full.lazy.flat_map do |rec|
          begin
            @record_class.build(mint_id(get_identifier(rec)),
                                record_xml(rec))
          rescue => e
            Krikri::Logger.log(:error, e.message)
            next
          end
        end
      end
    end

    ##
    # Gets a single record with the given identifier from the OAI endpoint
    #
    # @param identifier [#to_s] the identifier of the record to get
    # @param opts [Hash] options to pass to the OAI client
    def get_record(identifier, opts = {})
      opts[:identifier] = identifier
      opts = @opts.merge(opts)
      @record_class.build(mint_id(identifier),
                          record_xml(client.get_record(opts).record))
    end

    ##
    # Lists the sets available from the OAI endpoint. Accepts a block to
    # pass to `#map` on the resulting array.
    #
    # @example:
    #
    #   sets(&:spec)
    #
    # @param opts [Hash] options to pass to the OAI client
    # @return [Array<OAI::Set>] an array of sets.
    #
    # @see OAI::Set
    def sets(opts = {}, &block)
      arry = client.list_sets.full.to_a
      return arry unless block_given?
      arry.map(&block)
    end

    ##
    # @return [Hash] A hash documenting the allowable options to pass to
    #   initializers.
    #
    # @see Krikri::Harvester::expected_opts
    def self.expected_opts
      {
        key: :oai,
        opts: {
          set: { type: :string, required: false, multiple_ok: true },
          skip_set: { type: :string, required: false, multiple_ok: true },
          metadata_prefix: { type: :string, required: false },
          from: { type: :string, required: false },
          until: { type: :string, required: false },
          id_path: { type: :string, required: false }
        }
      }
    end

    ##
    # Concatinates two enumerators
    # @todo find a better home for this. Reopen Enumerable? or use the
    #    `Enumerating` gem: https://github.com/mdub/enumerating
    def concat_enum(enum_enum)
      Enumerator.new do |yielder|
        enum_enum.each do |enum|
          enum.each { |i| yielder << i }
        end
      end
    end

    private

    ##
    # Runs the request in the given block against the sets specified in `opts`.
    # Results are concatenated into a single enumerator.
    # 
    # Sets that respond with an error (`OAI::Exception`) will return empty 
    # and be skipped.
    #
    # @param opts [Hash] the options to pass, including all sets to process.
    # @yield gives options to the block once for each set. The
    #   block should run the harvest action with the options and give an
    #   Enumerable.
    # @yieldparam set_opts [Hash]
    # @yieldreturn [Enumerable] a result set to wrap into the retured lazy 
    #   enumerator
    #
    # @return [Enumerator::Lazy] A lazy enumerator concatenating the results
    #   of the block with each set.
    def request_with_sets(opts, &block)
      sets = Array(opts.delete(:set))
      if opts[:skip_set]
        sets = self.sets(&:spec) if sets.empty?
        skips = Array(opts.delete(:skip_set))
        sets.reject! { |s| skips.include? s }
      end
      sets = [nil] if sets.empty?

      set_enums = sets.lazy.map do |set|
        set_opts = opts.dup
        set_opts[:set] = set unless set.nil?
        begin
          yield(set_opts) if block_given?
        rescue OAI::Exception => e
          Krikri::Logger.log :warn, "Skipping set #{set} with error: #{e}"
          []
        end
      end
      concat_enum(set_enums).lazy
    end

    ##
    # Transforms an OAI::Record to xml suitable for saving with the
    # OriginalRecord. It's necessary to build a new document and add the 
    # namespace manually to normalize record output between `ListRecords` and
    # `GetRecord` requests.
    #
    # @param rec [OAI::Record]
    # @return [String] an xml string
    def record_xml(rec, as_doc: false)
      doc = Nokogiri.XML(rec._source.to_s)
      doc.root
        .add_namespace_definition(nil, 'http://www.openarchives.org/OAI/2.0/')
      as_doc ? doc : doc.to_xml
    end

    private

    def get_identifier(record)
      return record.header.identifier unless @id_path

      xml = record_xml(record, as_doc: true)
      ns = xml.collect_namespaces.map do |k, v|
        [k.gsub('xmlns:', ''), v]
      end

      begin
        ids = xml.xpath(@id_path, ns.to_h)
      rescue Nokogiri::XML::XPath::SyntaxError => e
        raise Krikri::Harvester::IdentifierError, 
              "No identifier at #{@id_path} for #{record.header.identifier}\n" \
              "\t#{e.message}"
      end
      
      if ids.empty?
        raise Krikri::Harvester::IdentifierError, 
              "No identifier at #{@id_path} for #{record.header.identifier}"
      end
      
      ids.first.text
    end
  end
end
