module Krikri::MappingDSL
  ##
  # Implements methods for accessing parsed values in MappingDSL
  module ParserMethods
    extend ActiveSupport::Concern

    def record
      lambda do |rec|
        yield rec.root if block_given?
      end
    end
  end
end
