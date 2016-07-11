module Krikri::Enrichments
  ##
  # Builds and sets a `prefLabel` based on existing begin/end dates within an 
  # `edm:TimeSpan`.
  #
  # @example
  #   date = DPLA::MAP::TimeSpan.new.tap do |t| 
  #     t.begin = Date.today
  #     t.end = (Date.today + 1)
  #   end
  #
  #   TimespanLabel.new.enrich_value(date).prefLabel
  #   # => ["2016-07-08/2016-07-09"]
  #
  class TimespanLabel
    include Audumbla::FieldEnrichment

    ##
    # Add a prefLabel for `DPLA::MAP::TimeSpan` objects with begin/end dates
    #
    # @param value [DPLA::MAP::TimeSpan, String, Object]
    #
    # @return [DPLA::MAP::TimeSpan, Object] a new `TimeSpan` object containing
    #   the generated prefLabel
    def enrich_value(value)
      set_label(value) if value.is_a?(DPLA::MAP::TimeSpan) && 
                          value.prefLabel.empty?
      value
    end

    private

    ##
    # @param  [DPLA::MAP::TimeSpan]
    # @return [void] 
    def set_label(value)
      start  = value.begin.sort.first
      finish = value.end.sort.last

      if start.nil? || finish.nil? || (start == finish)
        date            = start || finish
        value.prefLabel = date.to_s if date
      else
        value.prefLabel = EDTF::Interval.new(start, finish).to_s
      end
    end
  end
end
