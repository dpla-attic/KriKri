module Krikri
  ##
  # Provider is an ActiveModel object. It represents a provider that has been
  # indexed in Solr.
  #
  # This is a read-only object. It does not write new providers to Solr, nor
  # does it update or delete providers.
  #
  # A DPLA::MAP::Agent object can be constructed from an instance of this
  # ActiveModel object using the :agent method. The DPLA::MAP::Agent object
  # interacts with Marmotta, rather than Solr.
  #
  #   @example Krikri::Provider.find(rdf_subject: 'http://blah.com/123').agent
  #     => [DPLA::MAP::Agent]
  #
  class Provider
    include ActiveModel::Validations
    include ActiveModel::Conversion
    extend ActiveModel::Naming

    ##
    # @!attribute :rdf_subject [String] the URI identifying the provider
    #   @example: "http://blah.com/contributor/123"
    #
    # @!attribute :id [String] the stub id
    #   @example: "123"
    #
    # @!attribute :name [String] the human-redable name of the provider
    #
    # @!attribute :agent [DPLA::MAP::Agent] an ActiveTriples representation of
    # the provider, read from Marmotta.
    attr_accessor :rdf_subject, :name
    attr_reader :agent, :id

    ##
    # Initializes a Provider object.
    #
    # @param attributes [Hash]
    # If the params Hash contains a valid value for :rdf_subject, the model can
    # extrapolate all other attributes.
    #
    # @example
    #   Krikri::Provider.new({ rdf_subject: 'http:://blah.com/contributor/123',
    #                          name: 'Moomin Valley Historical Society' })
    #
    # @raise [NoMethodError] if the params Hash includes a key that does not
    # match listed attr_accessors
    #
    # @return [<Krikri::Provider>]
    def initialize(attributes = {})
      attributes.each do |name, value|
        send("#{name}=", value)
      end
    end

    ##
    # Gives a list of all providers, ignoring those with no URI (bnodes).
    #
    # Providers will be initialized with both an :rdf_subject and a :name,
    # if both exist in the Solr index.
    #
    # @return [Array<Krikri::Provider>]
    def self.all
      query_params = { :rows => 0,
                       :id => '*:*',
                       :facet => true,
                       'facet.pivot' => 'provider_id,provider_name' }
      response = Krikri::SolrResponseBuilder.new(query_params).response

      response.facet_pivot['provider_id,provider_name'].map do |facet|
        rdf_subject = facet['value']
        name = facet['pivot'].present? ? facet['pivot'].first['value'] : nil
        provider = new({ :rdf_subject => rdf_subject, :name => name })
        provider.valid_rdf_subject? ? provider : nil
      end.compact
    end

    ##
    # Finds a provider in Solr that matches the given ID, ignoring bnodes.
    #
    # @param [String] :id or :rdf_subject
    #
    # @return [Krikri::Provider]
    def self.find(id)
      rdf_subject = id.start_with?(base_uri) ? id : base_uri + id
      query_params = { :rows => 1,
                       :q => rdf_subject,
                       :qf => 'provider_id',
                       :fl => 'provider_id provider_name' }
      response = Krikri::SolrResponseBuilder.new(query_params).response
      return nil unless response.docs.count > 0
      new({ :rdf_subject => rdf_subject,
            :name => response.docs.first['provider_name'].first })
    end

    ##
    # Get the base of the :rdf_subject for any provider
    # @return [String] ending in "/"
    def self.base_uri
      base_uri = Krikri::Settings.prov.provider_base
      base_uri.end_with?('/') ? base_uri : base_uri << '/'
    end

    def id
      @id ||= local_name
    end

    def name
      @name ||= initialize_name
    end

    def agent
      @agent ||= initialize_agent
    end

    ##
    # Tests for providers that have valid a :rdf_subject (not a bnode).
    # A valid :rdf_subject does not necessarily match and :rdf_subject in the
    # Solr index, but it has the correct URI format.
    def valid_rdf_subject?
      return false unless rdf_subject.present?
      rdf_subject.start_with?(self.class.base_uri) ? true : false
    end

    ##
    # Required ActiveModel method.
    def persisted?
      false
    end

    private

    ##
    # Gives the last path fragment for :rdf_subject in HTML escaped form,
    # ignoring :rdf_subjects, ignoring bnodes.
    #
    # @example
    #   Given: rdf_subject == 'http://my_domain/blah/0123'
    #   local_name == '0123'
    #
    # @return [String]
    def local_name
      return nil unless valid_rdf_subject?
      rdf_subject.split('/').last.html_safe
    end

    ##
    # Gives the :provider_name associated with a provider's :rdf_subject
    # (ie. :provider_id) in Solr, ignoring bnodes.
    #
    # @return [String]
    def initialize_name
      return nil unless valid_rdf_subject?
      query_params = { :rows => 1,
                       :q => rdf_subject,
                       :qf => 'provider_id',
                       :fl => 'provider_name provider_id' }
      response = Krikri::SolrResponseBuilder.new(query_params).response
      return nil unless response.docs.count > 0
      response.docs.first['provider_name'].respond_to?(:first) ?
        response.docs.first['provider_name'].first : rdf_subject
    end

    ##
    # Creates DPLA::MAP::Agent object from the :rdf_subject and :name, ignoring
    # bnodes.
    #
    # @return [DPLA::MAP::Agent]
    def initialize_agent
      return nil unless valid_rdf_subject?
      DPLA::MAP::Agent.new(rdf_subject).tap { |agent| agent.label = name }
    end
  end
end
