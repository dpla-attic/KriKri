module Krikri
  ##
  # Wrapper module for enrichments
  module Enrichments
    autoload :RemoveEmptyFields,    'krikri/enrichments/remove_empty_fields'
    autoload :SplitAtDelimiter,     'krikri/enrichments/split_at_delimiter'
  end
end
