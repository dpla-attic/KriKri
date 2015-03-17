require 'resque/server'

Krikri::Engine.routes.draw do
  # TODO: remove unnecessary :harvest_sources and :institutions routes once we
  # have established what we do and don't need
  resources :validation_reports, only: [:index]
  resources :records, only: [:index, :show]
  resources :report_lists, only: [:index]
  resources :institutions do
    resources :harvest_sources, shallow: true
  end
  resources :activities, only: [:index]
  mount Resque::Server.new, at: '/resque'
end
