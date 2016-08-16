##
# Require 'blacklight' before 'krikri/engine' to ensure that view order is
# configured properly.
require 'rails'
require 'devise'
require 'blacklight'
require 'blacklight/gallery'
require 'audumbla'
require 'krikri/engine'

module Krikri
  autoload :XmlParser,        'krikri/parsers/xml_parser'
  autoload :OaiDcParser,      'krikri/parsers/oai_dc_parser'
  autoload :JsonParser,       'krikri/parsers/json_parser'
  autoload :ModsParser,       'krikri/parsers/mods_parser'
  autoload :QdcParser,        'krikri/parsers/qdc_parser'
  autoload :MARCXMLParser,    'krikri/parsers/marcxml_parser'
  autoload :PrimoParser,      'krikri/parsers/primo_parser'
  autoload :OaiParserHeaders, 'krikri/parsers/oai_parser_headers'
  autoload :AggregationEntityBehavior,
           'krikri/entity_behaviors/aggregation_entity_behavior'
  autoload :OriginalRecordEntityBehavior,
           'krikri/entity_behaviors/original_record_entity_behavior'

end
