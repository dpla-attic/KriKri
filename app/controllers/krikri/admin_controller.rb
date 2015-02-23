module Krikri
  class AdminController < ApplicationController
    def index
      @providers = Krikri::ProviderList.new.provider_names
    end
  end
end
