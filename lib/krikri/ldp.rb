module Krikri
  ##
  # Namespace module for tools supporting LDP/Marmotta.
  # As LDP support develops, it might be possible to excract this or replace it
  # with a tool like the `ldp` gem.
  module LDP
    autoload :Resource,     'krikri/ldp/resource'
    autoload :RdfSource,    'krikri/ldp/rdf_source'
  end
end
