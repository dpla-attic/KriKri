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
    include Krikri::FieldEnrichment

    ##
    # Enrich a `DPLA::MAP::Place' object by splitting the string given
    # in its `lat' or `long'.
    #
    # @param place [DPLA::MAP::Place]
    # @return [DPLA::MAP::Place]
    #
    def enrich_value(place)
      return place if !place.is_a? DPLA::MAP::Place

      # place.lat and place.long are arrays of one value if they are assigned.

      return place if place.lat.first && place.long.first  # no split required

      if place.lat.first
        latlong = coord_values(place.lat.first)
        assign_latlong!(place, latlong.first, latlong.last)
      elsif place.long.first
        latlong = coord_values(place.long.first)
        assign_latlong!(place, latlong.last, latlong.first)
      end

      place
    end

    def assign_latlong!(place, lat, long)
      # We have to assign these one at a time because we can't do this:
      # place.lat, place.long = [[nil], [nil]]
      # ... which results in:
      #     "value must be an RDF URI, Node, Literal, or a valid datatype.
      #     See RDF::Literal. You provided nil"
      # ... although this works fine:
      # place.lat, place.long = [['10.0'], ['11.1']]
      place.lat = lat
      place.long = long
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
    # @return [Array]
    def coord_values(s)
      coords = s.split(/ *, */)
      return [nil, nil] if coords.size != 2
      coords.map! { |c| c.to_f.to_s == c ? c : nil }   # must be decimal ...
      return [nil, nil] unless coords[0] && coords[1]  # ... i.e. not nil
      [coords[0], coords[1]]
    end
  end
end
