# -*- encoding : utf-8 -*-
#
require 'blacklight/catalog'

##
# Implements catalog controller to be deployed when the engine is included in
# a Rails/Blacklight application.
class CatalogController < ApplicationController
  include Blacklight::Catalog

  configure_blacklight do |config|
    ##
    # Default parameters to send to solr for all search-like requests.
    # See also SolrHelper#solr_search_params.
    config.default_solr_params = {
      :qt => 'search',
      :rows => 10
    }

    # solr field configuration for search results/index views
    config.index.title_field = 'sourceResource_title'

    # solr fields that will be treated as facets by the blacklight application
    #   The ordering of the field names is the order of the display
    #
    # Setting a limit will trigger Blacklight's 'more' facet values link.
    # * If left unset, then all facet values returned by solr will be displayed.
    # * If set to an integer, then "f.somefield.facet.limit" will be added to
    # solr request, with actual solr request being +1 your configured limit --
    # you configure the number of items you actually want _displayed_ in a page.
    # * If set to 'true', then no additional parameters will be sent to solr,
    # but any 'sniffed' request limit parameters will be used for paging, with
    # paging at requested limit -1. Can sniff from facet.limit or
    # f.specific_field.facet.limit solr request params. This 'true' config
    # can be used if you set limits in :default_solr_params, or as defaults
    # on the solr side in the request handler itself. Request handler defaults
    # sniffing requires solr requests to be made with "echoParams=all", for
    # app code to actually have it echo'd back to see it.
    #
    # :show may be set to false if you don't want the facet to be drawn in the
    # facet bar

    config.add_facet_field 'sourceResource_type_id', :label => 'Type'
    config.add_facet_field 'sourceResource_format', :label => 'Format'
    config.add_facet_field 'sourceResource_spatial_name', :label => 'Place'
    config.add_facet_field 'sourceResource_subject_name', :label => 'Subject'
    config.add_facet_field('sourceResource_collection_title',
                           :label => 'Collection')
    config.add_facet_field 'dataProvider_name', :label => 'Data Provider'
    config.add_facet_field 'sourceResource_creator_name', :label => 'Creator'

    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.add_facet_fields_to_solr_request!

    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display
    config.add_index_field 'id', :label => 'ID'
    config.add_index_field 'sourceResource_description', :label => 'Description'
    config.add_index_field 'sourceResource_date_providedLabel', :label => 'Date'
    config.add_index_field 'sourceResource_type_id', :label => 'Type'
    config.add_index_field 'sourceResource_format', :label => 'Format'
    config.add_index_field 'sourceResource_rights', :label => 'Rights'
    config.add_index_field 'dataProvider_name', :label => 'Data Provider'

    config.index.thumbnail_field = :preview_id

    # TODO: Decide whether we want the show (single result) view metadata
    # to come from the search index or from marmotta
    #
    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display
    config.add_show_field 'sourceResource_title', :label => 'Title'
    config.add_show_field 'sourceResource_description', :label => 'Description'
    config.add_show_field 'sourceResource_date_providedLabel', :label => 'Date'
    config.add_show_field 'sourceResource_type_id', :label => 'Type'
    config.add_show_field 'sourceResource_format', :label => 'Format'
    config.add_show_field 'sourceResource_rights', :label => 'Rights'
    config.add_show_field 'dataProvider_name', :label => 'Data Provider'
    config.add_show_field 'sourceResource_creator_name', :label => 'Creator'
    config.add_show_field 'sourceResource_spatial_name', :label => 'Place'
    config.add_show_field 'sourceResource_subject_name', :label => 'Subject'
    config.add_show_field('sourceResource_collection_title',
                          :label => 'Collection')
  end
end
