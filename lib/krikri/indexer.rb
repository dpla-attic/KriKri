module Krikri
  ##
  # A SoftwareAgent to run indexing processes.
  #
  # @example To index records enriched by the enrichment activity with ID 3:
  #   Krikri::Indexer.enqueue({
  #     index_class: 'Krikri::QASearchIndex',
  #     generator_uri: 'http://ldp.local.dp.la/ldp/activity/3'
  #     some_option_for_index_class: 'abc'
  #   })
  #
  # The options hash contains options for the `Indexer` as well as the
  # `SearchIndex`.
  #
  # @todo use generalized `EntityConsumer` interface that is independent from
  #   `Activity`. `#index` needs to be largely rewritten due to 
  #   `#update_from_activity`, which is tighly bound to `Activity` rather than
  #   `Enumerator<#entities>`.
  # @see Krikri::SoftwareAgent#enqueue
  class Indexer
    include SoftwareAgent
    include EntityConsumer

    attr_reader :index, :index_class, :index_opts

    def self.queue_name
      :indexing
    end

    def initialize(opts = {})
      assign_generator_activity!(opts)
      @index_class = opts.delete(:index_class)
      @index_opts = opts
    end

    def index
      @index ||= index_class.constantize.new(index_opts)
    end

    def run
      index.update_from_activity(generator_activity)
    end
  end
end
