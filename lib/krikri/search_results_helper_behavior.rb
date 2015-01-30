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

  end
end
