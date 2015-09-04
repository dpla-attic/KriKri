##
# Require 'blacklight' before 'krikri/engine' to ensure that view order is
# configured properly.
require 'rails'
require 'devise'
require 'blacklight'
require 'audumbla'
require 'krikri/engine'

module Krikri
  autoload :XmlParser,        'krikri/parsers/xml_parser'
  autoload :OaiDcParser,      'krikri/parsers/oai_dc_parser'
  autoload :JsonParser,       'krikri/parsers/json_parser'
  autoload :ModsParser,       'krikri/parsers/mods_parser'
  autoload :QdcParser,        'krikri/parsers/qdc_parser'
  autoload :MARCXMLParser,    'krikri/parsers/marcxml_parser'
  autoload :OaiParserHeaders, 'krikri/parsers/oai_parser_headers'
  autoload :AggregationEntityBehavior,
           'krikri/entity_behaviors/aggregation_entity_behavior'
  autoload :OriginalRecordEntityBehavior,
           'krikri/entity_behaviors/original_record_entity_behavior'
end

##
# Monkey-patch the EBNF Scanner to catch larger terminals.
#
# @see https://github.com/gkellogg/ebnf/issues/5
module EBNF::LL1
  class Scanner
    def initialize(input, options = {})
      # use an arbitrarily large low/high water mark. We want to make sure we're
      # feeding in the entire terminal
      @options = options.merge(:high_water => 1_048_576, 
                               :low_water => 1_048_576)

      if input.respond_to?(:read)
        @input = input
        super("")
        feed_me
      else
        super(input.to_s)
      end
    end
  end
end
