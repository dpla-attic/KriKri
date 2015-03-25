module Krikri
  class ApplicationController < ActionController::Base
    include Concerns::ProviderContext

    before_action :authenticate_user!, :set_current_provider
  end
end
