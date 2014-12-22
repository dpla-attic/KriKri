require 'resque/server'

Krikri::Engine.routes.draw do
  # TODO: remove unnecessary :harvest_sources and :institutions routes once we
  # have established what we do and don't need
  resources :institutions do
    resources :harvest_sources, shallow: true
  end
  mount Resque::Server.new, at: '/resque'
end
