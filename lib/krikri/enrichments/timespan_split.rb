module Krikri::Enrichments
  ##
  # Splits edm:TimeSpan labels and populates `#begin` and `#end`. Any values
  # generated from string values are left as strings to be normalized by
  # another enrichment.
  #
  # Ignores values that are neither a String or an edm:TimeSpan
  #
  # Converts string values to a timespan with the value as providedLabel
  # and enriches as below.
  #
  # Populates the `#begin`, and `#end` properties of TimeSpan objects from
  # `#providedLabel`. If a `#providedLabel` is present, but begin and end are
  # missing, runs the `Krikri::Util::ExtendedDateParser`.
  #
  # Once a begin and end date are recognized, the enrichment checks their
  # validity (that the begin date comes before any existing end dates, or vice
  # versa) and writes whichever value(s) it finds empty.  The earliest/latest
  # dates are used for begin/end, respectively.
  #
  # If more than one `#providedLabel` is given, each is processed in turn and
  # the widest possible range is used.
  #
  # Returns the TimeSpan unaltered if both `#begin` and `#end` are present
  # or valid values cannot be found for empty fields.
  #
  # @see Krikri::Util::ExtendedDateParser
  class TimespanSplit
    include Krikri::FieldEnrichment

    ##
    # Enrich a `DPLA::MAP::TimeSpan` object or string value with `begin` and
    # `end` values.
    #
    # @param value [DPLA::MAP::TimeSpan, String, Object]
    #
    # @return [Object] a new `TimeSpan` object containing the providedLabel
    #   and the enriched begin/end; if given a value other than a `TimeSpan`
    #   or `String` returns that value.
    def enrich_value(value)
      value = timespan_from_string(value) if value.is_a? String
      return value unless value.is_a? DPLA::MAP::TimeSpan
      populate_timespan(value)
    end

    ##
    # Converts a string to a `DPLA::MAP::TimeSpan` with the string as
    # `providedLabel`.
    #
    # @param [String] a string value containing a date, time, or timespan
    #
    # @return [DPLA::MAP::TimeSpan] a new, empty timespan with `providedLabel`
    def timespan_from_string(value)
      timespan = DPLA::MAP::TimeSpan.new
      timespan.providedLabel = value
      timespan
    end

    ##
    # Populates a timespan with a begin and end date.
    #
    # @param timespan [DPLA::MAP::TimeSpan]
    #
    # @return [DPLA::MAP::TimeSpan]
    def populate_timespan(timespan)
      return timespan unless (timespan.begin.empty? || timespan.end.empty?) &&
        !timespan.providedLabel.empty?

      parsed = parse_labels(timespan.providedLabel)
      return timespan if parsed.empty?
      parsed.each do |date|
        begin_date, end_date = span_from_date(date)
        timespan.begin << begin_date
        timespan.end << end_date
      end
      reduce_to_largest_span(timespan)
      return timespan
    end

    ##
    # @return [Array<Date, EDTF::Interval>]
    def parse_labels(labels)
      labels.map { |l| Krikri::Util::ExtendedDateParser.parse(l, true) }.compact
    end

    ##
    # Converts an EDTF date to a begin and end date.
    #
    # @param date [Date, DateTime, EDTF::Interval] a date, with or without EDTF
    #   precision features; or an interval.
    #
    # @return [Array<Date, DateTime>] an array of two elements containing the
    #   begin and end dates.
    def span_from_date(date)
      return [nil, nil] if date.nil?
      if date.is_a?(Date)
        return [date, date] if date.precision == :day
        return [date, (date.succ - 1)]
      end
      [(date.respond_to?(:first) ? date.first : date.from),
       (date.respond_to?(:last) ? date.last : date.to)]
    end

    ##
    # Reduces a timespan with multiple begin or end dates to a single earliest
    # begin date and a single latest end date.
    #
    # @param timespan [DPLA::MAP::TimeSpan] the timespan to reduce
    #
    # @return [DPLA::MAP::TimeSpan] an updated timespan
    def reduce_to_largest_span(timespan)
      timespan.begin = timespan.begin.sort.first
      timespan.end = timespan.end.sort.last
      timespan
    end
  end
end
