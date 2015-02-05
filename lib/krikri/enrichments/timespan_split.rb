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

    def enrich_value(value)
      value = timespan_from_string(value) if value.is_a? String
      return value unless value.is_a? DPLA::MAP::TimeSpan
      populate_timespan(value)
    end

    def timespan_from_string(value)
      timespan = DPLA::MAP::TimeSpan.new
      timespan.providedLabel = value
      timespan
    end

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

    def parse_labels(labels)
      labels.map { |l| Krikri::Util::ExtendedDateParser.parse(l, true) }.compact
    end

    def span_from_date(date)
      return [nil, nil] if date.nil?
      return [date, date] if date.is_a? Date
      [(date.respond_to?(:first) ? date.first : date.from),
       (date.respond_to?(:last) ? date.last : date.to)]
    end

    def reduce_to_largest_span(timespan)
      timespan.begin = timespan.begin.sort.first
      timespan.end = timespan.end.sort.last
      timespan
    end
  end
end
