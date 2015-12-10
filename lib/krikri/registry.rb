module Krikri
  ##
  # Provides a registry of defined items that can be looked up by a token
  # symbol.
  #
  # The implementation is a singleton class, the instance is an enumerable 
  # tracking items registered.
  #
  # Expected to be extended as needed within other modules.
  #
  # @example creating a new registry
  #   Registry = Class.new(Krikri::Registry)
  #   Registry.register(:key, value)
  #   Registry.get(:key) # => value
  # 
  # @see Krikri::Harvester::Registry
  # @see Krikri::Mapper::Registry
  class Registry
    include Singleton
    include Enumerable

    attr_reader :items
    delegate :each, :[], :[]=, to: :items

    def initialize
      @items = {}
    end

    class << self
      ##
      # @param name [Symbol] the key to access
      #
      # @raise [RuntimeError] when the item is not registered
      def get(name)
        raise "#{name} is not registered." unless registered? name
        instance[name]
      end

      ##
      # @param name [Symbol] the key to register
      # @param item [Object] the registry entry
      #
      # @return [Object] the item registered to the given key name
      # @raise [RuntimeError] when the item is already registered
      def register(name, item)
        raise "#{name} is already registered." if registered? name
        register!(name, item)
      end

      ##
      # Registers an item, overwriting any existing item with the given key name
      # @param name [Symbol] the key to register
      # @param item [Object] the registry entry
      #
      # @return [Object] the item registered to the given key name
      def register!(name, item)
        instance[name] = item
      end

      ##
      # @param name [Symbol] the key to check
      # @return [Boolean] true if the key name is registered; false otherwise
      def registered?(name)
        instance.items.keys.include? name
      end

      ##
      # @return [Array<Symbol>]
      def keys
        instance.items.keys
      end
    end
  end
end
