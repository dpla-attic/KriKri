module Krikri
  # Marshalls HarvestSources for views
  class HarvestSourcesController < ApplicationController

    def show
      @harvest_source = HarvestSource.find(params[:id])
    end

  end
end
