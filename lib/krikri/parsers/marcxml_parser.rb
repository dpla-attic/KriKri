module Krikri
  ##
  # A MARCXML parser. Uses XML parser with a root path to match the
  # metadata path.
  # @see Krikri::XmlParser
  class MARCXMLParser < XmlParser
    include Krikri::OaiParserHeaders

    def initialize(record, root_path = '//marc:record', ns = {})
      ns = { marc: 'http://www.loc.gov/MARC21/slim' }.merge(ns)
      super(record, root_path, ns)
    end
  end
end
