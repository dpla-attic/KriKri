module Krikri
  ##
  # Concern for Krikri::XmlParsers with oai-style headers
  # @example
  #    class MyOaiParser < Krikri::XmlParser
  #      include Krikri::OaiParserHeaders
  #    end
  module OaiParserHeaders
    extend ActiveSupport::Concern

    ##
    # @return [Krikri::Parser::ValueArray] a ValueArray containing the
    #   header node as a `Value` of this parser class
    def header
      header_node = Nokogiri::XML(record.to_s).at_xpath('//xmlns:header')
      Krikri::Parser::ValueArray
        .new([self.class::Value.new(header_node, root.namespaces)])
    end
  end
end
