module Krikri
  # This module helps controllers that display results from a querying the
  # search index.
  module SearchResultsHelperBehavior

    # Override method in Blacklight::CatalogHelperBehavior.
    def render_thumbnail_tag(document, image_options = {}, url_options = {})
      link_to image_tag(thumbnail_url(document)), url_for_document(document)
    end

    # Override method in Blacklight::UrlHelperBehavior.
    def link_to_document(document, field_or_opts = nil, opts = {})
      link_to field_or_opts, url_for_document(document)
    end

    # This method is used to make display fields into hyperlinks.
    def make_this_a_link(options = {})
      # options[:document] # the original document
      # options[:field] # the field to render
      # options[:value] # the value of the field

      link_to options[:value], options[:value]
    end

    # This method is used to link display fields to the document's show path.
    def link_to_show(options = {})
      # options[:document] # the original document
      # options[:field] # the field to render
      # options[:value] # the value of the field

      link_to_document options[:document], options[:value]
    end

    def render_document_field_data(document, key)
      if document[key]
        render_index_field_value document, :field => key
      end
    end

    # Disable bookmarks.
    def render_bookmarks_control?
      false
    end

    # Render enriched record for view
    # @param [Krikri::SearchIndexDocument]
    # @return [String]
    def render_enriched_record(document)
      agg = document.aggregation
      return error_msg('Aggregation not found.') unless agg.present?
      JSON.pretty_generate(agg.to_jsonld)
    end

    # Render original record for view
    # @param [Krikri::SearchIndexDocument]
    # @return [String]
    def render_original_record(document)
      agg = document.aggregation
      return error_msg('Aggregation not found.') unless agg.present?

      begin
        original_record = agg.original_record
      rescue StandardError => e
        logger.error e.message
        return error_msg(e.message)
      end

      return error_msg('Original record not found.') unless
        original_record.present?
      prettify_string(original_record.to_s, original_record.content_type)
    end

    private

    def prettify_string(string, mime_type)
      string = prettify_json_string(string) if mime_type.include? 'json'
      string = prettify_xml_string(string) if mime_type.include? 'xml'
      string
    end

    def prettify_json_string(string)
      begin
        return JSON.pretty_generate(JSON.parse(string))
      rescue JSON::ParserError
        return string
      end
    end

    def prettify_xml_string(string)
      if Nokogiri.XML(string).errors.empty?
        doc = Nokogiri.XML(string) { |c| c.noblanks }
        return doc.to_xml(indent: 2)
      end
      string
    end

    def error_msg(message = '')
      "There was a problem getting the record.\n\n#{message}"
    end

    def random_record_url
      url_for_document(Krikri::RandomRecordGenerator.new.record)
    end
  end
end
