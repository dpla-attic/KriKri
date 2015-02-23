module Krikri
  ##
  # An OAI DC parser. Uses XML parser with a root path to match the
  # metadata path as harvested from OAI-PMH.
  # @see Krikri::XmlParser
  class OaiDcParser < XmlParser
    include Krikri::OaiParserHeaders

    def initialize(record, root_path = '//oai_dc:dc')
      super
    end
  end
end
