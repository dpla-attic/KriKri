require 'resque/server'

Krikri::Engine.routes.draw do
  # TODO: remove unnecessary :harvest_sources and :institutions routes once we
  # have established what we do and don't need
  resources :validation_reports, only: [:show]
  resources :records, only: [:index, :show]
  resources :reports, only: [:index]
  resources :qa_reports, only: [:index, :show]
  resources :institutions do
    resources :harvest_sources, shallow: true
  end

  resources :providers, only: [:index, :show]

  mount Resque::Server.new, at: '/resque'
end
