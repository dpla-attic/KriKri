module Krikri
  ##
  # A SoftwareAgent handling post-harvest data cleanup.
  # 
  # These cleanup processes are ...
  #
  # @example
  # 
  class Cleaner
    include SoftwareAgent
    
    ##
    # @return [Enumerator<Krikri::LDP::Invalidatable>]
    def records
      [DPLA::MAP::Aggregation.new('123')]
    end

    ##
    # Invalidates selected records; silently skips records already invalidated.
    #
    # @param activity_uri [RDF::URI, nil]
    #
    # @return [Boolean] `true` if the run has succeeded; otherwise `false`
    # @raise [RuntimeError] if non-invalidatable records, or records that do not
    #   exist (`#exists? => false`) are selected
    # @see SoftwareAgent#run
    def run(activity_uri = nil)
      records.each { |rec| rec.invalidate!(activity_uri, true) }
    end
  end
end
