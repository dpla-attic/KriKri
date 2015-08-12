module Krikri
  ##
  # ActiveModelBase is a Superclass for ActiveModel objects.
  class ActiveModelBase
    include ActiveModel::Conversion
    include ActiveModel::Dirty
    include ActiveModel::Validations
    extend ActiveModel::Naming

    ##
    # Initializes a Krikri::ActiveModelBase object.
    #
    # @param attributes [Hash]
    #
    # @raise [NoMethodError] if the params Hash includes a key that does not
    # match any of the Class's writeable attributes.
    #
    # @example
    #   Given: MyActiveModel is a subclass of ActiveModelBase
    #   Given: :name is a writeable attribute of MyActiveModel
    #   MyActiveModel.new({ :name => 'value' })
    #
    # @return [Krikri::ActiveModelBase]
    def initialize(attributes = {})
      attributes.each do |name, value|
        send("#{name}=", value)
      end
    end

    ##
    # Required ActiveModel method.
    def persisted?
      false
    end
  end
end
