require 'rails'
require 'devise'
require "krikri/engine"
require 'blacklight'

module Krikri
  # autoload Krikri::XMLParser
  autoload :XmlParser,      'krikri/parsers/xml_parser'
  # autoload Krikri::OaiDcParser
  autoload :OaiDcParser,    'krikri/parsers/oai_dc_parser'
  autoload :JsonParser,     'krikri/parsers/json_parser'
  autoload :ModsParser,     'krikri/parsers/mods_parser'

  # Enrichments
  autoload :Enrichment,       'krikri/enrichment'
  autoload :FieldEnrichment,  'krikri/field_enrichment'
  autoload :Enrichments,      'krikri/enrichments'
end
