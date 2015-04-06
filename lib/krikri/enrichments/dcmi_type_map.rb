# coding: utf-8
module Krikri::Enrichments
  ##
  # Maps string values to DCMI Type vocabulary terms.
  #
  # Mapping is performed by comparing a hash of string keys to the pre-enriched
  # value, using White Similarity comparisons to determine the closest match. If
  # a suitable match is found, a {DLPA::MAP::Controlled::DCMIType} object is
  # built from the appropriate hash value and set as the new value.
  #
  # This enrichment ignores strings without a DCMI Type match.
  #
  # @example
  #
  #   type_mapper = DcmiTypeMap.new
  #   type_mapper.enrich_value('image') # finds RDF::DCMITYPE.Image
  #   type_mapper.enrich_value('a book') # finds RDF::DCMITYPE.Text
  #   type_mapper.enrich_value('a really cool book') # => 'a really cool book'
  #
  # @example
  #
  #   type_mapper = DcmiTypeMap.new('poloriod' => RDF::DCMIType.Image)
  #   type_mapper.enrich_value('poloroid.') # finds RDF::DCMITYPE.Image
  #
  class DcmiTypeMap
    include Krikri::FieldEnrichment

    DEFAULT_MAP = { 'image' => RDF::DCMITYPE.Image,
                    'photograph' => RDF::DCMITYPE.Image,
                    'sample book' => RDF::DCMITYPE.Image,
                    'specimen' => RDF::DCMITYPE.Image,
                    'textile' => RDF::DCMITYPE.Image,
                    'frame' => RDF::DCMITYPE.Image,
                    'costume' => RDF::DCMITYPE.Image,
                    'statue' => RDF::DCMITYPE.Image,
                    'sculpture' => RDF::DCMITYPE.Image,
                    'container' => RDF::DCMITYPE.Image,
                    'jewelry' => RDF::DCMITYPE.Image,
                    'furnishing' => RDF::DCMITYPE.Image,
                    'furniture' => RDF::DCMITYPE.Image,
                    'drawing' => RDF::DCMITYPE.Image,
                    'print' => RDF::DCMITYPE.Image,
                    'painting' => RDF::DCMITYPE.Image,
                    'illumination' => RDF::DCMITYPE.Image,
                    'poster' => RDF::DCMITYPE.Image,
                    'appliance' => RDF::DCMITYPE.Image,
                    'tool' => RDF::DCMITYPE.Image,
                    'electronic component' => RDF::DCMITYPE.Image,
                    'postcard' => RDF::DCMITYPE.Image,
                    'equipment' => RDF::DCMITYPE.Image,
                    'cartographic' => RDF::DCMITYPE.Image,
                    'notated music' => RDF::DCMITYPE.Image,
                    'mixed material' => RDF::DCMITYPE.Image,
                    'text' => RDF::DCMITYPE.Text,
                    'book' => RDF::DCMITYPE.Text,
                    'publication' => RDF::DCMITYPE.Text,
                    'magazine' => RDF::DCMITYPE.Text,
                    'journal' => RDF::DCMITYPE.Text,
                    'correspondence' => RDF::DCMITYPE.Text,
                    'writing' => RDF::DCMITYPE.Text,
                    'written' => RDF::DCMITYPE.Text,
                    'manuscript' => RDF::DCMITYPE.Text,
                    'audio' => RDF::DCMITYPE.Sound,
                    'sound' => RDF::DCMITYPE.Sound,
                    'oral history recording' => RDF::DCMITYPE.Sound,
                    'finding aid' => RDF::DCMITYPE.Collection,
                    'online collection' => RDF::DCMITYPE.Collection,
                    'electronic resource' => RDF::DCMITYPE.InteractiveResource,
                    'video game' => RDF::DCMITYPE.InteractiveResource,
                    'online exhibit' => RDF::DCMITYPE.InteractiveResource,
                    'moving image' => RDF::DCMITYPE.MovingImage,
                    'movingimage' => RDF::DCMITYPE.MovingImage,
                    'motion picture' => RDF::DCMITYPE.MovingImage,
                    'film' => RDF::DCMITYPE.MovingImage,
                    'video' => RDF::DCMITYPE.MovingImage,
                    'object' => RDF::DCMITYPE.PhysicalObject
                  }

    ##
    # @param map [Hash<String, RDF::Vocabulary::Term>]
    def initialize(map = nil)
      @map = map || DEFAULT_MAP
    end

    ##
    # @param value [Object] the value to enrich
    #
    # @return [DPLA::MAP::Controlled::DCMIType, nil] the matching DCMI Type
    #   term. `nil` if no matches are found.
    def enrich_value(value)
      return value unless value.is_a? String

      match = @map.fetch(value.downcase) { most_similar(value) }
      return value if match.nil?
      dcmi = DPLA::MAP::Controlled::DCMIType.new(match)
      dcmi.prefLabel = match.label
      dcmi
    end


    private

    ##
    # Performs White Similarity comparison against the keys, and gives the
    # value of the closest match.
    #
    # @param value [String] a string value to compare to the hash map keys.
    # @param threshold [Float] the value at which a string is considered to
    #   be a match
    #
    # @return [RDF::Vocabulary::Term, nil] the closest DCMI type match, or `nil`
    #   if none is sufficiently close
    #
    # @see Text::WhiteSimilarity
    # @see http://www.catalysoft.com/articles/strikeamatch.html article defining
    #   the White Similarity algorithm
    #
    # @todo consider text similarity algorithms/strategies and move text
    #   matching to a utility and behind a Facade interface.
    def most_similar(value, threshold = 0.5)
      @white ||= Text::WhiteSimilarity.new
      result = @map.max_by { |str, _| @white.similarity(value, str) }

      return result[1] if @white.similarity(value, result.first) > threshold
      nil
    end
  end
end
