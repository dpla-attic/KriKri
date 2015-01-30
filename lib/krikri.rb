##
# Require 'blacklight' before 'krikri/engine' to ensure that view order is 
# configured properly.
require 'rails'
require 'devise'
require 'blacklight'
require "krikri/engine"

module Krikri
  autoload :XmlParser,      'krikri/parsers/xml_parser'
  # autoload Krikri::OaiDcParser
  autoload :OaiDcParser,    'krikri/parsers/oai_dc_parser'
  autoload :JsonParser,     'krikri/parsers/json_parser'
  autoload :ModsParser,     'krikri/parsers/mods_parser'
  autoload :QdcParser,      'krikri/parsers/qdc_parser'
end
