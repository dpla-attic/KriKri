module Krikri
  ##
  # Descriptive Metadata for OriginalRecord
  class OriginalRecordMetadata < ActiveTriples::Resource
    include Krikri::LDP::RdfSource

    configure base_uri: Krikri::Settings.marmotta.record_container

    property :created, predicate: RDF::DC.created
    property :modified, predicate: RDF::DC.modified
    property :hasFormat, predicate: RDF::DC.hasFormat
    property :wasGeneratedBy, predicate: RDF::PROV.wasGeneratedBy
  end
end
