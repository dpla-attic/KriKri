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

    def new
      @institution = Institution.new
    end

    def create
      @institution = Institution.new(institution_params)
      if @institution.save
        redirect_to @institution
      else
        render 'new'
      end
    end

    def edit
      @institution = Institution.find(params[:id])
    end

    def update
      @institution = Institution.find(params[:id])
      if @institution.update(institution_params)
        redirect_to @institution
      else
        render 'edit'
      end
    end

    def destroy
      @institution = Institution.find(params[:id])
      @institution.destroy
      redirect_to institutions_path
    end

    private

    def institution_params
      params.require(:institution).permit(:name, :notes)
    end

  end
end
