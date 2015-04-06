# coding: utf-8
module Krikri::Enrichments
  ##
  #
  class DcmiTypeMap
    include Krikri::FieldEnrichment

    DEFAULT_MAP = { 'image' => RDF::DCMIType.Image,
                    'photograph' => RDF::DCMIType.Image,
                    'sample book' => RDF::DCMIType.Image,
                    'specimen' => RDF::DCMIType.Image,
                    'textile' => RDF::DCMIType.Image,
                    'frame' => RDF::DCMIType.Image,
                    'costume' => RDF::DCMIType.Image,
                    'statue' => RDF::DCMIType.Image,
                    'sculpture' => RDF::DCMIType.Image,
                    'container' => RDF::DCMIType.Image,
                    'jewelry' => RDF::DCMIType.Image,
                    'furnishing' => RDF::DCMIType.Image,
                    'furniture' => RDF::DCMIType.Image,
                    'drawing' => RDF::DCMIType.Image,
                    'print' => RDF::DCMIType.Image,
                    'paniting' => RDF::DCMIType.Image,
                    'illumination' => RDF::DCMIType.Image,
                    'poster' => RDF::DCMIType.Image,
                    'appliance' => RDF::DCMIType.Image,
                    'tool' => RDF::DCMIType.Image,
                    'electronic component' => RDF::DCMIType.Image,
                    'postcard' => RDF::DCMIType.Image,
                    'equipment' => RDF::DCMIType.Image,
                    'cartographic' => RDF::DCMIType.Image,
                    'notated music' => RDF::DCMIType.Image,
                    'mixed material' => RDF::DCMIType.Image,
                    'text' => RDF::DCMIType.Text,
                    'book' => RDF::DCMIType.Text,
                    'publication' => RDF::DCMIType.Text,
                    'magazine' => RDF::DCMIType.Text,
                    'journal' => RDF::DCMIType.Text,
                    'correspondence' => RDF::DCMIType.Text,
                    'writing' => RDF::DCMIType.Text,
                    'manuscript' => RDF::DCMIType.Text,
                    'audio' => RDF::DCMIType.Sound,
                    'sound' => RDF::DCMIType.Sound,
                    'oral history recording' => RDF::DCMIType.Sound,
                    'finding aid' => RDF::DCMIType.Collection,
                    'online collection' => RDF::DCMIType.Collection,
                    'electronic resource' => RDF::DCMIType.InteractiveResource,
                    'video game' => RDF::DCMIType.InteractiveResource,
                    'online exhibit' => RDF::DCMIType.InteractiveResource,
                    'moving image' => RDF::DCMIType.MovingImage,
                    'movingimage' => RDF::DCMIType.MovingImage,
                    'motion picture' => RDF::DCMIType.MovingImage,
                    'film' => RDF::DCMIType.MovingImage,
                    'video' => RDF::DCMIType.MovingImage,
                    'object' => RDF::DCMIType.PhysicalObject,
                  }

    def initialize(map = nil)
      @map = map || DEFAULT_MAP
    end

    def enrich_value(value)
      return value unless value.is_a? String
      @map.fetch(value.downcase
    end
  end
end
