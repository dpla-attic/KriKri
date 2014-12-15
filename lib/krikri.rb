require 'rails'
require 'devise'
require "krikri/engine"
require 'blacklight'

module Krikri
  # autoload libraries
  autoload :IndexService,   'krikri/index_service'
  autoload :Mapper,         'krikri/mapper'
  autoload :Mapping,        'krikri/mapping'
  autoload :MappingDSL,     'krikri/mapping_dsl'
  autoload :Parser,         'krikri/parser'

  # parsers
  autoload :XmlParser,      'krikri/parsers/xml_parser'
  autoload :OaiDcParser,    'krikri/parsers/oai_dc_parser'

  # Enrichments
  autoload :Enrichment,     'krikri/enrichment'
  autoload :Enrichments,    'krikri/enrichments'
end
