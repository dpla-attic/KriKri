module Krikri::Util
  module ExtendedDateParser
    module_function

    ##
    # Attempts to parse a string into a valid EDTF or `Date` format.
    #
    #   - Attempts to split `#providedLabel` on '-', '/', '..', 'to', 'until', and
    #     looks for EDTF and `Date.parse` patterns on either side, setting them to
    #     `#begin` and `#end`. Both split and unsplit dates are parsed as follows:
    #   - Attempts to parse `#providedLabel` as an EDTF interval and populates
    #     begin and end with their respective values.
    #   - Attempts to match to a number of regular expressions which specify
    #     ranges informally.
    #   - Attempts to parse `#providedLabel` as a single date value with
    #     `Date.parse` and enters that value to both `#begin` and `#end`.
    #
    # @param date_str [String] a string which may contain a date range
    # @param allow_interval [Boolean] a flag specifing whethe to use
    #   #range_match to look for range values.
    #
    # @return [Date, EDTF::Epoch, EDTF::Interval, nil] the date parsed or nil
    def parse(date_str, allow_interval = false)
      date_str.strip!
      date_str.gsub!(/\s+/, ' ')
      date = parse_interval(date_str) if allow_interval
      date ||= parse_m_d_y(date_str)
      date ||= Date.edtf(date_str.gsub('.', '-'))
      date ||= partial_edtf(date_str)
      date ||= decade_hyphen(date_str)
      date ||= month_year(date_str)
      date ||= decade_s(date_str)
      date ||= hyphenated_partial_range(date_str)
      date ||= parse_date(date_str)
      date || nil
    end

    ##
    # Matches a wide variety of date ranges separated by '..' or '-'
    #
    # @param str [String] a string which may contain a date range
    # @return [Array(String)] the begining and ending dates of an identified
    #    range
    def range_match(str)
      str = str.gsub('to', '-').gsub('until', '-')
      regexp = %r{
        ([a-zA-Z]{0,3}\s?[\d\-\/\.xu\?\~a-zA-Z]*,?\s?
        \d{3}[\d\-xs][s\d\-\.xu\?\~]*)
        \s*[-\.]+\s*
        ([a-zA-Z]{0,3}\s?[\d\-\/\.xu\?\~a-zA-Z]*,?\s?
        \d{3}[\d\-xs][s\d\-\.xu\?\~]*)
      }x
      regexp.match(str) do |m|
        [m[1], m[2]]
      end
    end

    ##
    # Creates an EDTF::Interval from a string
    #
    # @param str [String] a string which may contain a date range
    # @return [ETDF::Interval, nil] an EDTF object representing a date range
    #   or nil if none can be found
    #
    # @see #range_match
    def parse_interval(str)
      match = range_match(str)
      return nil if match.nil?

      begin_date, end_date = match.map { |date| parse(date) || :unknown }

      begin_date = begin_date.first if begin_date.respond_to? :first
      end_date = end_date.last if end_date.respond_to? :last

      EDTF::Interval.new(begin_date, end_date)
    end

    ##
    # Runs `Date#parse`; if arguments are invalid (as with an invalid date
    # string) returns `nil`.
    #
    # @return [Date, nil] the parsed date or nil
    # @see Date#parse
    def parse_date(*args)
      begin
        Date.parse(*args)
      rescue ArgumentError
        nil
      end
    end

    ##
    # Runs `Date#strptime` with '%m-%d-%Y'; if arguments are invalid (as with
    # an invalid date string) returns `nil`.
    #
    # @param value [String] the string to parse
    # @return [Date, nil] the parsed date or nil
    # @see Date#strptime
    def parse_m_d_y(value)
      begin
        Date.strptime(value.gsub(/[^0-9]/, '-'), '%m-%d-%Y')
      rescue ArgumentError
        nil
      end
    end

    ##
    # e.g. 01-2045
    def month_year(str)
      /^(\d{2})-(\d{4})$/.match(str) do |m|
        Date.edtf("#{m[2]}-#{m[1]}")
      end
    end

    ##
    # e.g. 1990-92
    def hyphenated_partial_range(str)
      /^(\d{2})(\d{2})-(\d{2})$/.match(str) do |m|
        Date.edtf("#{m[1]}#{m[2]}/#{m[1]}#{m[3]}")
      end
    end

    ##
    # e.g. 1970-08-01/02 or 1970-12/10
    def partial_edtf(str)
      /^(\d{4}(-\d{2})*)-(\d{2})\/(\d{2})$/.match(str) do |m|
        Date.edtf("#{m[1]}-#{m[3]}/#{m[1]}-#{m[4]}")
      end
    end

    ##
    # e.g. 1990s
    def decade_s(str)
      /^(\d{3})0s$/.match(str) do |m|
        Date.edtf("#{m[1]}x")
      end
    end

    ##
    # e.g. 199-
    def decade_hyphen(str)
      /^(\d{3})-$/.match(str) do |m|
        Date.edtf("#{m[1]}x")
      end
    end
  end
end
