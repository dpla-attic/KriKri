module Krikri
  # HarvestSource models user-submitted information about a harvest source
  # Some data may be used to create a Harvester
  class HarvestSource < ActiveRecord::Base
    ##
    # A validator for harvest source/harvester options.
    # 
    # @see Krikri::Harvester.expected_opts
    # @see ActiveModel::Validations::ClassMethods#validates_with
    class OptionsValidator < ActiveModel::Validator
      def validate(record)
        unless record.harvester_class.valid_opts?(record.build_opts)
          record.errors[:options] << 
            "Options must include required options for #{source_type}"
        end
      end
    end

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

    validates_with OptionsValidator

    ##
    # @return [Krikri::Harvester]
    def build_harvester
      harvester_class.new(build_opts)
    end

    ##
    # @return [Class] A class implementing `Krikri::Harvester`
    def harvester_class
      Krikri::Harvester::Registry.get(source_key)
    end

    ##
    # @retern [Hash] harvester options
    def build_opts
      opts = { uri: uri }
      opts[harvester_class.key] = {}
      # opts[:name] = @harvester_name if @harvester_name
      opts
    end
    
    private

    ##
    # @private
    # @return [Symbol] the Harvester::Registry key for the harvester
    def source_key
      source_type.downcase.to_sym
    end
  end
end
