module Krikri
  # Constructs a list of Validation Reports
  class ValidationReportList
    attr_reader :report_list

    REQUIRED_FIELDS = ['dataProvider_name', 'isShownAt_id', 'preview_id',
                       'sourceResource_rights', 'sourceResource_title',
                       'sourceResource_type_id']

    def initialize
      @blacklight_config = Blacklight::Configuration.new
      @report_list = list_for_display(missing_field_totals)
    end

    ##
    # Returns the number of items missing each required field
    # @return Array
    def missing_field_totals
      solr_params = {
        :rows => 0,
        'facet.field' => REQUIRED_FIELDS,
        'facet.mincount' => 10000000,
        'facet.missing' => true
      }
      Blacklight::SolrRepository.new(@blacklight_config).search(solr_params)
    end

    # Transform Hash of key-value pairs into Array of Hashes.
    #   example: { "field_name"=>[nil,2] } is tranformed into
    #   [{ :label => "field_name (2)", :link_url => "validation_reports?[...]"}]
    def list_for_display(solr_response)

      if solr_response && solr_response['facet_counts'] &&
         fields = solr_response['facet_counts']['facet_fields']

        return fields.each_with_object([]) do |(key, value), array|
          array << report_link(key, value[1])
        end
      end

      nil
    end

    # Construct a link and display label for a validation report
    # The param 'report_name' in the constructed link is not used by Solr
    #  - it is for display purposes only
    # @param: String, int
    # @return: Hash
    def report_link(name, count)
      link = { :label => "#{name} (#{count})" }

      if count > 0
        link[:url] = "validation_reports?q=-#{name}:[*%20TO%20*]" \
                     "&report_name=#{name}"
      end

      link
    end

  end
end
