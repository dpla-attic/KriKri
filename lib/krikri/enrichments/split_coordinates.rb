module Krikri::Enrichments
  ##
  # Splits a string given in `lat' or `long' in an edm:Place object and
  # assigns `lat' and `long' with the split values.
  #
  # @example
  #
  #   Where val is a DPLA::MAP::Place,
  #   and val.lat == '40.7127,74.0059',
  #   assign val.lat = '40.7127' and val.long = '74.0059'
  #
  #   If long is filled in instead of lat, the values will be assigned in the
  #   reverse order, with lat taking '74.0059' and long taking '40.7127'.
  #
  class SplitCoordinates
    include Audumbla::FieldEnrichment

    ##
    # Enrich a `DPLA::MAP::Place' object by splitting the string given
    # in its `lat' or `long'.
    #
    # place.lat and place.long are ActiveTriples::Terms, we only care
    # about the first value. If multiple values are given, this enrichment
    # will remove them.
    #
    # @param place [DPLA::MAP::Place]
    #
    # @return [DPLA::MAP::Place]
    def enrich_value(place)
      return place if !place.is_a? DPLA::MAP::Place
      return place unless splittable?(place.lat) || splittable?(place.long)

      if place.lat.any?
        latlong = coord_values(place.lat.first)
        assign_latlong!(place, latlong.first, latlong.last)
      elsif place.long.any?
        latlong = coord_values(place.long.first)
        assign_latlong!(place, latlong.last, latlong.first)
      end

      place
    end

    def assign_latlong!(place, lat, long)
      place.lat = lat if lat
      place.long = long if long
    end

    ##
    # Given a String `s', return an array of two elements split on a comma
    # and any whitespace around the comma.
    #
    # If the string does not split into two strings representing decimal
    # values, then return [nil, nil] because the string does not make sense as
    # coordinates.
    #
    # @param s [String]  String of, hopefully, comma-separated decimals
    #
    # @return [Array]
    def coord_values(s)
      coords = s.split(/ *, */)
      return [nil, nil] if coords.size != 2
      coords.map! { |c| c.to_f.to_s == c ? c : nil }   # must be decimal ...
      return [nil, nil] unless coords[0] && coords[1]  # ... i.e. not nil
      [coords[0], coords[1]]
    end

    private

    ##
    # @param value [ActiveTriples::Term<String>]
    #
    # @return [Boolean] true if value contains a string with a ','; false
    #   otherwise
    def splittable?(value)
      return false if value.empty?
      value.first.include? ','
    end
  end
end
