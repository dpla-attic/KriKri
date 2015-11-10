module Krikri
  ##
  # A Primo parser. Uses XML parser with a root path to match the
  # metadata path.
  # @see Krikri::XmlParser
  class PrimoParser < XmlParser
    DEFAULT_NAMESPACE = 'nmbib'

    def self.record(*args)
      ['PrimoNMBib', 'record', *args].map { |s| "#{DEFAULT_NAMESPACE}:#{s}" }
    end

    def self.display(*args)
      record('display', *args)
    end

    def self.search(*args)
      record('search', *args)
    end

    def initialize(record,
                   root_path = '//sear:DOC',
                   ns = {nmbib: 'http://www.exlibrisgroup.com/xsd/primo/primo_nm_bib'})
      super(record, root_path, ns)
    end
  end
end
