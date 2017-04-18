module Krikri
  ##
  # A parser for the Smithsonian XML format. Uses XML parser with a root path to match the
  # metadata path.
  # @see Krikri::XmlParser
  class SmithsonianParser < XmlParser
    include Krikri::OaiParserHeaders

    def initialize(record, root_path = '//doc', ns = {})
      super(record, root_path, ns)
    end
  end
end
