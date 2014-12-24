require 'rails'
require 'devise'
require "krikri/engine"
require 'blacklight'

module Krikri
  # autoload Krikri::XMLParser
  autoload :XmlParser,      'krikri/parsers/xml_parser'
  # autoload Krikri::OaiDcParser
  autoload :OaiDcParser,    'krikri/parsers/oai_dc_parser'
end
