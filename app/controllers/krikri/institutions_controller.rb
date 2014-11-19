module Krikri
  # Marshalls Institutions for views
  class InstitutionsController < ApplicationController

    def index
      @institutions = Institution.all
    end

    def show
      @institution = Institution.find(params[:id])
      @harvest_sources = @institution.harvest_sources
    end

  end
end
