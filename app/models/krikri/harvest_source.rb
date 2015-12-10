module Krikri
  # HarvestSource models user-submitted information about a harvest source
  # Some data may be used to create a Harvester
  class HarvestSource < ActiveRecord::Base
    belongs_to :institution
    validates_presence_of :institution, :name, :source_type, :uri

    validates_each :source_type do |record, attr, val|
      if val.nil? || 
         !(Krikri::Harvester::Registry.registered?(val.downcase.to_sym))
        record.errors.add(:attr, 'source_type must exist in Harvester registry')
      end
    end

    validates :uri,
              format: { with: URI.regexp },
              if: proc { |a| a.uri.present? }
    
    def build_harvester
      harvester_class.new(build_opts)
    end

    # def validate_options!
    #   harvester_class.validate_opts!(opts)
    # end

    private

    ##
    # @private
    # @retern [Hash] harvester options
    def build_opts
      opts = { uri: uri }
      # opts[harvester_class.expected_opts[:key]] = options
      # harvester_class.validate_opts!(opts)
      opts
    end
    
    ##
    # @private
    # @return [Class] A class implementing `Krikri::Harvester`
    def harvester_class
      Krikri::Harvester::Registry.get(source_key)
    end

    ##
    # @private
    # @return [Symbol] the Harvester::Registry key for the harvester
    def source_key
      source_type.downcase.to_sym
    end
  end
end
