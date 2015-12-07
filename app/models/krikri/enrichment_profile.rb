module Krikri
  ##
  # A formal enrichment profile, specifying an ordered list of enrichment 
  # classes, their initialization parameters, and the input/output fields they
  # apply to in the context of the profile.
  # 
  # Replaces the old Hash based enrichment profiles exemplified by
  # https://gist.github.com/no-reply/0646fe3b7a43a53a794a
  #
  # @example creating a profile
  #
  #   profile = Krikri::EnrichmentProfile.new
  #   
  class EnrichmentProfile < ActiveRecord::Base

    ##
    # Specifies a single enrichment.
    class Enrichment
      attr_reader :input_fields

      ##
      # @param klass [Class, String] a class (or constantizable string) that 
      #   implements `Audumbla::Enrichment`
      # @param input_fields []
      # @param output_fields [] 
      # @param args [Array<Object>] arguments to pass to klass on initialization
      def initialize(klass, input_fields: :all, output_fields: nil, args: [])
        @klass         = klass
        @input_fields  = input_fields
        @output_fields = output_fields
      end

      def build
        require 'pry'; binding.pry
      end

      def valid?
        begin
          constantize
        rescue NameError
          return false
        end
      end
      
      private
      
      def constantize
        @klass.constantize
      end
    end
  end
end
