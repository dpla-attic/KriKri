module Krikri
  ##
  # Marshals SolrDocuments for views.
  # Sets default Solr request params for Validation Reports.
  #
  # ValidationReportsController inherits from the host application's
  # ApplicationController.  It does not interit from Krikri's
  # ApplicationController.
  class ValidationReportsController < CatalogController
    include Krikri::QaProviderFilter
    before_action :authenticate_user!, :authenticate_session_provider
    before_action :valid_params, :only => :index
    self.solr_search_params_logic += [:records_by_provider]

    ##
    # ValidationReportsController has access to views in the following
    # directories:
    #   krikri/validation_reports
    #   catalog (defined in Blacklight)
    # It inherits view templates from the host application's
    # ApplicationController.  It uses krikri's application layout:
    layout 'krikri/application'

    configure_blacklight do |config|

      # Default parameters to send to solr for all search-like requests.
      config.default_solr_params = {
        :qt => 'standard',
        :rows => 100
      }

      # solr fields to be displayed in the index (search results) view
      #   The ordering of the field names is the order of the display
      config.add_index_field 'sourceResource_title', :label => 'Title',
                             helper_method: 'link_to_show'
      config.add_index_field 'id', :label => 'ID', helper_method: 'link_to_show'
      config.add_index_field 'isShownAt_id', :label => 'Is Shown At',
                             helper_method: 'make_this_a_link'

      config.show.route = { controller: 'records' }

      config.solr_document_model = Krikri::SearchIndexDocument
    end

    private

    def valid_params
      redirect_to :report_lists if !params['report_name'] || !params['q']
    end
  end
end
