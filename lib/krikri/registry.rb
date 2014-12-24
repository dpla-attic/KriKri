module Krikri

  ##
  # Provide a registry of defined items that can be looked up by a token
  # symbol.
  #
  # Expected to be extended as needed within other modules.
  # @see Krikri::Harvester::Registry
  # @see Krikri::Mapper::Registry
  #
  class Registry
    include Singleton
    include Enumerable

    attr_reader :items
    delegate :each, :[], :[]=, to: :items

    def initialize
      @items = {}
    end

    class << self

      def get(name)
        raise "#{name} is not registered." unless registered? name
        instance[name]
      end

      def register(name, item)
        raise "#{name} is already registered." if registered? name
        instance[name] = item
      end

      def registered?(name)
        instance.items.keys.include? name
      end

      def keys
        instance.items.keys
      end

    end

  end
end
