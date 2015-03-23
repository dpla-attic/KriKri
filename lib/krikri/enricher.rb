module Krikri
  ##
  # A SoftwareAgent that runs enrichment processes.
  #
  # @example
  #
  #   To enrich records that were mapped by the mapping activity with ID 3:
  #
  #   # Define which enrichments are run, and thier parameters:
  #   chain = {
  #     'Krikri::Enrichments::StripHtml' => {
  #       input_fields: [{sourceResource: :title}]
  #     },
  #     'Krikri::Enrichments::StripWhitespace' => {
  #       input_fields: [{sourceResource: :title}]
  #     }
  #   }
  #   Krikri::Enricher.enqueue({
  #     generator_uri: 'http://ldp.local.dp.la/ldp/activity/3',
  #     chain: chain
  #   })
  #
  # @see Krikri::SoftwareAgent#enqueue
  # @see Krikri::Enrichment
  #
  class Enricher
    include SoftwareAgent

    attr_reader :chain, :generator_uri

    def self.queue_name
      :enrichment
    end

    ##
    # Create a new Enricher, given a hash of options:
    #   generator_uri:  the LDP URI of the Activity that generated the mapped
    #      records that this one will enrich.
    #   chain:  a hash specifying the input_fields and output_fields, as
    #      illustrated above, which will be passed to the Enrichment.
    #
    # @see Krikri::Enrichment
    # @param opts [Hash] a hash of options
    def initialize(opts = {})
      @generator_uri = RDF::URI(opts.fetch(:generator_uri))
      @chain = deep_sym(opts.fetch(:chain) { {} })
    end

    ##
    # Run the enrichmnt.
    #
    # Take each record that was affected by the activity defined by our
    # instantiation, and apply each enrichment from the enrichment chain.
    #
    def run(activity_uri = nil)
      log :info, 'enricher is running'
      # see TODO below
      target_aggregations.each do |agg|
        begin
          chain_enrichments!(agg)
          activity_uri ? agg.save_with_provenance(activity_uri) : agg.save
        rescue => e
          log :error, "Enrichment error: #{e.message}\n#{e.backtrace}"
        end
      end
      log :info, 'enricher is done'
    end

    # TODO:  remove this when the current topic branch that introduces the
    # EntityConsumer mixin has been merged.
    def target_aggregations
      query = Krikri::ProvenanceQueryClient.find_by_activity(generator_uri)
      query.execute.lazy.flat_map do |solution|
        agg = DPLA::MAP::Aggregation.new(solution.record.to_s)
        agg.get
        agg
      end
    end

    ##
    # Given an aggregation, take each enrichment specified by the `chain'
    # given in our instantiation, and apply that enrichment, with the given
    # options, modifying the aggregation in-place.
    #
    def chain_enrichments!(agg)
      chain.keys.each do |e|
        enrichment = e.to_s.constantize.new
        if enrichment.is_a? Krikri::FieldEnrichment
          agg = do_field_enrichment(agg, enrichment, chain[e])
        else
          agg = do_basic_enrichment(agg, enrichment, chain[e])
        end
      end
    end

    private

    ##
    # Perform a default enrichment, using Enrichment#enrichment or a derived
    # class that expects the same arguments.
    #
    # @param agg [DPLA::MAP::Aggregation]
    # @param enrichment [Krikri::Enrichment]
    # @param options [Hash]
    #
    # @see Krikri::Enrichment
    #
    def do_basic_enrichment(agg, enrichment, options)
      enrichment.enrich(
        agg, options[:input_fields], options[:output_fields]
      )
    end

    ##
    # Perform a FieldEnrichment enrichment on the given aggregation.
    #
    # With FieldEnrichment#enrich, the input_fields option parameter is passed
    # as a variable arguments list
    #
    # @param agg [DPLA::MAP::Aggregation]
    # @param enrichment [Krikri::FieldEnrichment]
    # @param options [Hash]  Hash with :input_fields containing variable
    #                        arguments list
    #
    # @see Krikri::FieldEnrichment
    #
    def do_field_enrichment(agg, enrichment, options)
      enrichment.enrich(agg, *options[:input_fields])
    end

    ##
    # Transform the given hash recursively by turning all of its string keys
    # and values into symbols.
    #
    # Symbols are expected in the enrichment classes, and we will usually be
    # dealing with values that have been deserialized from JSON.
    #
    def deep_sym(obj)
      if obj.is_a? Hash
        return obj.inject({}) do |memo, (k, v)|
          memo[k.to_sym] = deep_sym(v)
          memo
        end
      elsif obj.is_a? Array
        return obj.inject([]) do |memo, el|
          memo << deep_sym(el)
          memo
        end
      elsif obj.respond_to? :to_sym
        return obj.to_sym
      else
        return nil
      end
    end
  end
end
