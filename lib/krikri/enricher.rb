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
  # @see Audumbla::Enrichment
  #
  class Enricher
    include SoftwareAgent
    include EntityConsumer

    attr_reader :chain, :generator_uri

    def self.queue_name
      :enrichment
    end

    ##
    # @see Krikri::Activity#entities
    # @see Krikri::EntityBehavior
    # @see Krikri::SoftwareAgent#entity_behavior
    def entity_behavior
      @entity_behavior ||= Krikri::AggregationEntityBehavior
    end

    ##
    # Create a new Enricher, given a hash of options:
    #   generator_uri:  the LDP URI of the Activity that generated the mapped
    #      records that this one will enrich.
    #   chain:  a hash specifying the input_fields and output_fields, as
    #      illustrated above, which will be passed to the Enrichment.
    #
    # @see Audumbla::Enrichment
    # @param opts [Hash] a hash of options
    def initialize(opts = {})
      @generator_uri = RDF::URI(opts.fetch(:generator_uri))
      @chain = deep_sym(opts.fetch(:chain) { {} })
      assign_generator_activity!(opts)
    end

    ##
    # Run the enrichmnt.
    #
    # Take each record that was affected by the activity defined by our
    # instantiation, and apply each enrichment from the enrichment chain.
    #
    def run(activity_uri = nil)
      log :info, 'enricher is running'
      mapped_records = generator_activity.entities
      mapped_records.each do |rec|
        begin
          chain_enrichments!(rec)
          activity_uri ? rec.save_with_provenance(activity_uri) : rec.save
        rescue => e
          log :error, "Enrichment error: #{e.message}\n#{e.backtrace}"
        end
      end
      log :info, 'enricher is done'
    end

    ##
    # Given an aggregation, take each enrichment specified by the `chain'
    # given in our instantiation, and apply that enrichment, with the given
    # options, modifying the aggregation in-place.
    #
    def chain_enrichments!(agg)
      chain.keys.each do |e|
        enrichment = enrichment_cache(e)
        if enrichment.is_a? Audumbla::FieldEnrichment
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
    # @param enrichment [Audumbla::Enrichment]
    # @param options [Hash]
    #
    # @see Audumbla::Enrichment
    #
    def do_basic_enrichment(agg, enrichment, options)
      enrichment.enrich(agg,
                        options[:input_fields],
                        options[:output_fields])
    end

    ##
    # Perform a FieldEnrichment enrichment on the given aggregation.
    #
    # With FieldEnrichment#enrich, the input_fields option parameter is passed
    # as a variable arguments list
    #
    # @param agg [DPLA::MAP::Aggregation]
    # @param enrichment [Audumbla::FieldEnrichment]
    # @param options [Hash]  Hash with :input_fields containing variable
    #                        arguments list
    #
    # @see Audumbla::FieldEnrichment
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

    ##
    # A cache of enrichment objects for the current instance. This allows
    # individual enrichment instances to maintain their own caches for the life
    # of a `#run`.
    def enrichment_cache(name)
      @enrichment_cache ||= {}
      @enrichment_cache[name] ||= name.to_s.constantize.new
    end
  end
end
