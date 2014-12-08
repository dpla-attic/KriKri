module Krikri::MappingDSL
  ##
  # Methods for setting URI/ActiveTriples #rdf_subject values in MappingDSL
  module RdfSubjects
    def uri(value, &block)
      properties.delete_if { |prop| prop.is_a? SubjectDeclaration }
      properties << SubjectDeclaration.new(nil, value, &block)
    end

    class SubjectDeclaration < Krikri::MappingDSL::PropertyDeclaration
      def to_proc
        block = @block if @block
        value = @value
        lambda do |target, record|
          value = value.call(record) if value.respond_to? :call
          raise 'URI must be set to a single value' if Array(value).count != 1
          value = value.first if value.is_a? Enumerable
          return target.send(setter, value) unless block
          target.send(setter, instance_exec(value, &block))
        end
      end

      private

      def setter
        :set_subject!
      end
    end
  end
end
