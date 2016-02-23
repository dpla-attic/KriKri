module Krikri::LDP
  ##
  # Implements invalidation for `Krikri::LDP::Resource`s. This is different 
  # from deletion, in that the resource continues to respond `200 OK`, and 
  # return the representation, Nothing is removed from the LDP server.
  # 
  # Works as a mixin to `Krikri::LDP::Resource`, assuming an implementation of
  # `#rdf_source`, which may simply return `self`.
  #
  # @example invalidating a resource
  #   class MyResource
  #     include Krikri::LDP::Resource
  #     include Krikri::LDP::Invalidatable
  #
  #     def rdf_subject
  #       @rdf_subject ||= RDF::URI('http://example.com/ldp/a/resource/path')
  #     end
  #   end
  #  
  #   invalidatable_resource = MyResource.new
  #   # the resource must exist before it can be invalidated! 
  #   invalidatable_resource.save
  #
  #   invalidatable_resource.invalidate!
  #   invalidatable_resource.invalidated? # => true
  #   invalidatable_resource.invalidated_at_time 
  #   # => Thu, 03 Dec 2015 10:27:45 -0800
  #
  # @see http://www.w3.org/TR/2013/REC-prov-dm-20130430/#term-Invalidation 
  #   for documentation on PROV invalidation
  module Invalidatable
    # @see RDF::PROV
    INVALIDATED_BY_URI =   RDF::Vocab::PROV.wasInvalidatedBy
    INVALIDATED_TIME_URI = RDF::Vocab::PROV.invalidatedAtTime

    ##
    # Invalidates the resource by marking it with a `prov:invalidatedAtTime`. If
    # an `RDF::Term` is passed as the first argument, that term is used as the 
    # value of `prov:wasInvalidatedBy`.
    #
    # @example invalidating with an activity
    #   invalidatable_resource.invalidate!(RDF::URI('http://example.org/moomin'))
    #   invalidatable_resource.was_invalidated_by
    #   # => #<RDF::URI:0x2acab846109c URI:http://example.org/moomin>
    #
    # @param activity_uri [RDF::Term] a URI for the invalidating activity. If 
    #   none is given, this defaults to `nil` and no `prov:wasInvalidatedBy`
    #   statement is added.
    # @param ignore_invalid [Boolean] if true, supresses errors on already,
    #   invalid records
    #
    # @raise [RuntimeError] when the resource does not exist or is already 
    #   invalid; unless `ignore_invalid` is `true`
    # @return [void]
    def invalidate!(activity_uri = nil, ignore_invalid = false)
      raise "Cannot invalidate #{rdf_subject}, does not exist." unless exists?

      # force a reload unless we have cached an invalidatedAtTime
      rdf_source.get({}, true) unless invalidated?
      # we check invalidated again in case the reload came back invalid
      if invalidated?
        return if ignore_invalid
        raise "Cannot invalidate #{rdf_subject}, already invalid." 
      end

      uri = RDF::URI(rdf_subject)
      
      rdf_source << [uri, INVALIDATED_BY_URI, activity_uri] unless 
        activity_uri.nil?
      rdf_source << [uri, INVALIDATED_TIME_URI, DateTime.now]

      rdf_source.save
    end

    ##
    # @return [Boolean] `true` if the resource has been marked invalidated.
    def invalidated?
      !invalidated_at_time.nil?
    end

    ##
    # @return [DateTime, nil] the time this resource was marked invalidated;
    #   gives `nil` if the resource has not been invalidated.
    # 
    # @note if two invalidatedAtTimes exist, we may get either of them back!
    def invalidated_at_time
      time = first_property(INVALIDATED_TIME_URI)
      time.nil? ? nil : time.object
    end

    ##
    # @return [RDF::URI, nil] the activity responsible for invalidating the 
    #   resource
    # 
    # @note if two wasInvalidatedBys exist, we may get either of them back!
    def was_invalidated_by
      first_property(INVALIDATED_BY_URI)
    end

    private 
    
    def first_property(predicate)
      res = rdf_source.query([RDF::URI(rdf_subject), predicate, nil])
      res.empty? ? nil : res.first.object
    end
  end
end
