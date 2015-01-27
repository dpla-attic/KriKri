module Krikri
  ##
  # A Qualified Dublin Core parser. Uses XML parser with a root path to match
  # the metadata path as harvested. The default root_path is the element used
  # by CONTENTdm; this can be overridden as with all Krikri::XmlParsers, at
  # the time of instantiation.
  #
  # @see Krikri::XmlParser
  class QdcParser < XmlParser
    def initialize(record, root_path = '//oai_qdc:qualifieddc', ns = {})
      ns = {
        qdc: 'http://epubs.cclrc.ac.uk/xmlns/qdc/',
        oai_qdc: 'http://worldcat.org/xmlschemas/qdc-1.0/'
      }.merge(ns)
      super(record, root_path, ns)
    end
  end
end
