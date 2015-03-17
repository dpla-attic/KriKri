module Krikri
  class ActivitiesController < ApplicationController
    before_action :authenticate_user!
    layout 'krikri/application'

    def index
      @activities = Krikri::Activity.order('id DESC').page params[:page]
    end
  end
end
