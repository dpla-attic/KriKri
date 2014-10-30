module Krikri
  ##
  # Handles records as harvested, prior to mapping
  class OriginalRecord
    def initialize(str_or_file)
      raise(ArgumentError,
            '`str_or_file` must be a readable IO object or String.'\
            "Got a #{str_or_file.class}") unless
        str_or_file.is_a?(String) || str_or_file.respond_to?(:read)
      @content = str_or_file
    end

    def to_s
      @content
    end

    def save
      # TODO: implement persistence/retrieval
      true
    end
  end
end
