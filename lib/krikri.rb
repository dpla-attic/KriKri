require 'rails'
require 'devise'
require "krikri/engine"
require 'blacklight'

module Krikri
  # autoload libraries
  autoload :IndexService,   'krikri/index_service'
end
