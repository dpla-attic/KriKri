require 'resque/server'

Krikri::Engine.routes.draw do
  # TODO: remove unnecessary :harvest_sources and :institutions routes once we
  # have established what we do and don't need
  resources :validation_reports, only: [:show]

  # Blacklight::CatalogController subclasses seem to have an issue where their
  # facet-related routes don't get automatically populated, leading to routing
  # errors when facet limits are enabled and the view attempts to render the
  # "more" links. This fix was suggested by Trey Terrell, demonstrated here:
  # https://github.com/OregonDigital/oregondigital/blob/d1653e41/config/routes.rb#L52-L56
  resources :records, only: [:index, :show] do
    collection do
      get "facet/:id", :to => "records#facet"
    end
  end

  resources :reports, only: [:index]
  resources :qa_reports, only: [:index, :show]
  resources :institutions do
    resources :harvest_sources, shallow: true
  end

  resources :providers, only: [:index, :show]

  mount Resque::Server.new, at: '/resque'
end
