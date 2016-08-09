module Krikri
  ##
  # FieldValueReport gives all unique values for a given field within a
  # document.  It represents data that has been indexed into Solr.
  #
  # This is a read-only object.  FieldValueReports are not persisted.
  class FieldValueReport < Krikri::ActiveModelBase
    ##
    # @!attribute :field [String] the name of the field.
    #   @example: 'sourceResource_title'
    #
    # @!attribute :provider [Krikri::Provider]
    attr_accessor :field, :provider

    ##
    # @param field [String] the name of the field being reported on
    #   @example: 'sourceResource_title'
    # @param provider_id [String] the id of the provider being reported on
    # These two params act as a compound key.
    #
    # @return [Krikri::FieldValueReport]
    def self.find(field, provider_id)
      return nil unless fields.include? field.to_sym
      provider = Krikri::Provider.find(provider_id)
      return nil unless provider.present?
      new({ :field => field,
            :provider => provider })
    end

    ##
    # All of the fields for which a report can be created.
    def self.fields
      [:dataProvider_providedLabel,
       :sourceResource_alternative_providedLabel,
       :sourceResource_collection_title,
       :sourceResource_contributor_providedLabel,
       :sourceResource_creator_providedLabel,
       :sourceResource_date_providedLabel,
       :sourceResource_description,
       :sourceResource_format,
       :sourceResource_genre_providedLabel,
       :sourceResource_language_providedLabel,
       :sourceResource_publisher_providedLabel,
       :sourceResource_rights,
       :sourceResource_rightsHolder_providedLabel,
       :sourceResource_spatial_providedLabel,
       :sourceResource_subject_providedLabel,
       :sourceResource_temporal_providedLabel,
       :sourceResource_title,
       :sourceResource_type_name]
    end

    ##
    # The headers for the report table, and the values to be returned from a
    # Solr query.
    def headers
      [:id, :isShownAt_id, field.to_sym]
    end

    ##
    # @param opts [Hash] optional parameters for the solr request
    #   @example: enumerate_rows(batch_size: 1000)
    # 
    # @return Enumerator[<Array>] an enumerator over the rows
    def enumerate_rows(opts = {})
      Enumerator.new do |yielder|
        loop do
          opts = query_opts(opts)
          response = Krikri::SolrResponseBuilder.new(opts).response
          break if response.docs.empty?

          parse_solr_response(response).each do |row|
            yielder <<  headers.map { |header| row[header] }
          end

          opts[:start] += opts[:rows]
          break if opts[:start] >= response.total
        end
      end
    end

    private

    ##
    # @param opts [Hash] additional options for the query params
    # @return [Hash] parameters for a Solr request
    def query_opts(opts = {})
      { :fq => "provider_id:\"#{provider.rdf_subject}\"",
        :fl => headers,
        :rows => opts.fetch(:rows, 1000).to_i,
        :start => opts.fetch(:start, 0).to_i }
    end

    ##
    # @param [Blacklight::SolrResponse] response
    # @return [Array<Hash>]
    #
    # The return Hashes should include keys for all headers defined in the
    # :headers method
    def parse_solr_response(response)
      rows = []

      response.docs.each do |doc|
        id = doc['id'].split('/').last
        isShownAt_id = doc['isShownAt_id'].respond_to?(:first) ?
          doc['isShownAt_id'].first : '__MISSING__'

        if doc[field].present?
          doc[field].each do |value|
            rows << { :id => id,
                      field.to_sym => value,
                      :isShownAt_id => isShownAt_id }
          end
        else
          rows << { :id => id,
                    field.to_sym => '__MISSING__',
                    :isShownAt_id => isShownAt_id }
        end
      end

      rows
    end
  end
end
