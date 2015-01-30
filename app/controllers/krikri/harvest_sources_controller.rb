module Krikri
  # Marshalls HarvestSources for views
  class HarvestSourcesController < ApplicationController

    BadRequestError = Class.new(RuntimeError)

    def index
      @harvest_sources =
        HarvestSource.where(institution_id: params[:institution_id])
      @institution = Institution.find(params[:institution_id])
    end

    def show
      @harvest_source = HarvestSource.find(params[:id])
    end

    def new
      @harvest_source = HarvestSource
                        .new(institution_id: params[:institution_id])
    end

    def edit
      @harvest_source = HarvestSource.find(params[:id])
    end

    def update
      @harvest_source = HarvestSource.find(params[:id])
      begin
        if @harvest_source.update(harvest_source_params)
          redirect_to @harvest_source
        else
          render 'edit'
        end
      rescue BadRequestError
        render nothing: true, status: :bad_request
      end
    end

    def create
      ok_params = harvest_source_params
      ok_params[:institution_id] = params[:institution_id]
      @harvest_source = HarvestSource.new(ok_params)
      if @harvest_source.save
        institution = Institution.find(params[:institution_id])
        redirect_to institution_path(institution)
      else
        render 'new'
      end
    end

    def destroy
      @harvest_source = HarvestSource.find(params[:id])
      institution = @harvest_source.institution
      @harvest_source.destroy!
      redirect_to institution_harvest_sources_path(institution)
    end

    private

    def harvest_source_params
      hs = params.require(:harvest_source)
      permitted =
        hs.permit(:name, :source_type, :metadata_schema, :uri, :notes)
      fail BadRequestError unless hs == permitted
      permitted
    end

  end
end
