module Krikri
  ##
  # Represents a QA Report, giving details about a set of records associated
  # with a given provider. Reports are given as structured hashes, containing
  # keys for each registered property in the {DPLA::MAP::Aggregation} structure.
  #
  # Reports include two report types, a `#field_report` and a `#count_report`.
  #
  # The `#field_report` includes values for each property with the URIs for the
  # `ore:Aggregation` and `edm:isShownAt` (`edm:WebResource`) associated with
  # that field.
  #
  # The `#count_report` includes values for each field, with the count occurances
  # for that value across all records for the provider.
  #
  # `QAReports` are saved to the database (with timestamp, etc... via
  # {ActiveRecord}). More than one report can be associated with each provider.
  #
  # Reports can also serialize themselves as `csv`, via `#field_csv` and
  # `#count_csv`.
  #
  # @example:
  #
  #   report = QAReport.create(provider: 'moomin_valley')
  #   report.generate_field_report!
  #   report.generate_count_report!
  #
  #   report.field_report['edm:aggregatedCHO->dc:alternative']
  #   => {"Stonewall Inn Graffiti"=>
  #      [{:aggregation=>"http://localhost:8983/marmotta/ldp/items/krikri_sample",
  #        :isShownAt=> "http://digitalcollections.nypl.org/items/12345"}]}
  #
  #   report.count_report['edm:aggregatedCHO->dc:alternative']
  #   => {"Stonewall Inn Graffiti"=>1}
  #
  # @see Krikri::QAQueryClient
  class QAReport < ActiveRecord::Base
    serialize :field_report, Hash
    serialize :count_report, Hash

    ##
    # Generates and saves the field report for the provider, sending SPARQL
    # queries as necessary.
    #
    # @return [Hash]
    def generate_field_report!
      report = field_queries.inject({}) do |report_hash, (k, v)|
        report_hash[k] = solutions_to_hash(v.execute)
        report_hash
      end
      update(field_report: report)
    end

    ##
    # Generates and saves the coun treport for the provider, sending SPARQL
    # queries as necessary.
    #
    # @return [Hash]
    def generate_count_report!
      report = count_queries.inject({}) do |report_hash, (k, v)|
        report_hash[k] = solutions_to_counts(v.execute)
        report_hash
      end

      update(count_report: report)
    end

    ##
    # @param include_fields
    #
    # @return [CSV::Table] a table containing values, aggregations, and
    #   isShownAt URLs for each included field
    def field_csv(*include_fields)
      fields = field_report.keys
      fields.select! { |f| include_fields.include? f } unless
        include_fields.empty?

      variables = [:value, :aggregation, :isShownAt]
      headers = fields.product(variables).map { |header| header.join(' ') }

      table = CSV::Table.new([CSV::Row.new(headers, [], true)])
      return table if field_report.nil? || field_report.empty?

      rows = []

      field_report.each do |field, values|
        values.each do |value, agg_list|
          agg_list.each_with_index do |agg_hash, i|
            rows[i] ||= CSV::Row.new(headers, [])
            rows[i]["#{field} value"] = value.to_s
            rows[i]["#{field} aggregation"] = agg_hash[:aggregation].to_s
            rows[i]["#{field} isShownAt"] = agg_hash[:isShownAt].to_s
          end
        end
      end

      rows.each { |r| table << r }
      table
    end

    ##
    # @param include_fields
    #
    # @return [CSV::Table] a table containing values and their counts
    #   for each included field
    def count_csv(*include_fields)
      fields = count_report.keys
      fields.select! { |f| include_fields.include? f } unless
        include_fields.empty?

      variables = [:value, :count]
      headers = fields.product(variables).map { |header| header.join(' ') }

      table = CSV::Table.new([CSV::Row.new(headers, [], true)])
      return table if count_report.nil? || count_report.empty?

      rows = []

      count_report.each do |field, hash|
        hash.to_a.each_with_index do |value, i|
          rows[i] ||= CSV::Row.new(headers, [])
          rows[i]["#{field} value"] = value.first.to_s
          rows[i]["#{field} count"] = value.last
        end
      end

      rows.each { |r| table << r }
      table
    end

    ##
    # Retrieves the provider as an object
    #
    # @return [Krikri::Provider] the provider as a populated
    #   {ActiveTriples::RDFSource}
    # @todo figure out a better relations pattern between {ActiveRecord} objects
    #   and {ActiveTriples}
    def build_provider
      Krikri::Provider.new(:rdf_subject => provider).agent
    end

    private

    ##
    # @return [Hash<SPARQL::Client::Query]
    def count_queries
      queries = {}
      each_property(DPLA::MAP::Aggregation).each do |properties|
        queries[property_name(properties)] =
          QAQueryClient.counts_for_predicate(properties,
                                             RDF::URI(build_provider.rdf_subject))
      end
      queries
    end

    ##
    # @return [Array<SPARQL::Client::Query]
    def field_queries
      queries = {}
      each_property(DPLA::MAP::Aggregation).each do |properties|
        queries[property_name(properties)] =
          QAQueryClient.values_for_predicate(properties,
                                             RDF::URI(build_provider.rdf_subject))
      end
      queries
    end

    ##
    # @param properties [Array<RDF::URI>] an array of URIs to join
    #
    # @return [String] a string representing the property array as qualified
    #   names
    def property_name(properties)
      properties.map(&:pname).join('->')
    end

    ##
    # @param solutions [RDF::Query::Solutions]
    # @return [Hash] a hash of values, aggregations, and isShownAt URIs
    def solutions_to_hash(solutions)
      matches = {}
      solutions.each do |solution|
        key = solution.value.to_s
        matches[key] ||= []
        matches[key] <<  { aggregation: solution.aggregation.to_s,
                           isShownAt: solution.isShownAt.to_s }

      end
      matches
    end

    ##
    # @param solutions [RDF::Query::Solutions]
    # @return [Hash] a hash of values and counts
    def solutions_to_counts(solutions)
      matches = {}
      solutions.each do |solution|
        count = solution[:count].to_i
        matches[solution.value.to_s] = count unless count == 0
      end
      matches
    end

    ##
    # Gives an enumerator for the properties on an {ActiveTriples::Resource}
    # class; #each/#next give an Array representing the property chain for each
    # property config that does not have a `class_name` (i.e. is configured as
    # a literal).
    #
    # @return [Enumerator] an deep enumerator over all registered
    #   properties
    # @todo move to {ActiveTriples}?
    def each_property(klass)
      nested_properties_list(klass).flatten(1).to_enum
    end

    ##
    # @param klass [#properties]
    #
    # @return [Array<Array<RDF::Term>>] An array of property predicates
    # @todo move to {ActiveTriples}?
    def nested_properties_list(klass)
      klass.properties.map do |_, config|
        properties = []
        if config.class_name.nil? || config.class_name == klass
          properties << Array(config.predicate)
        else
          nested_properties_list(config.class_name).each do |prop|
            prop.each do |p|
              properties << Array(config.predicate).append(p).flatten
            end
          end
        end
        properties
      end
    end
  end
end
