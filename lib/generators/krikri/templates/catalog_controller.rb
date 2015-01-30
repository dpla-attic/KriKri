# -*- encoding : utf-8 -*-
#
require 'blacklight/catalog'
# This Blacklight controller serves as a super class for Krikri controllers.
class CatalogController < ApplicationController
  include Blacklight::Catalog
end
