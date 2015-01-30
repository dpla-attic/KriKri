module Krikri
  class ApplicationController < ActionController::Base
    before_action :authenticate_user!
  end
end
