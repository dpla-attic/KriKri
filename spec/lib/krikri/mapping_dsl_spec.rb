require 'spec_helper'

describe Krikri::MappingDSL do
  include_context 'mapping dsl'

  it 'knows it responds to missing methods' do
    expect(mapping.respond_to?(:blah)).to be true
  end

  describe '#add_property' do
    describe 'static' do
      before do
        expect(Krikri::MappingDSL::PropertyDeclaration).to receive(:new)
          .with(:my_property, value).and_return(declaration)
        mapping.my_property value
      end

      let(:declaration) do
        instance_double(Krikri::MappingDSL::PropertyDeclaration,
                        :name => :my_property, :value => value)
      end

      it 'adds properties' do
        expect(mapping.properties).to include(declaration)
      end

      context 'with overwritten property' do
        before do
          expect(Krikri::MappingDSL::PropertyDeclaration).to receive(:new)
            .with(:my_property, 'new_value').and_return(new_declaration)
          mapping.my_property 'new_value'
        end

        let(:new_declaration) do
          instance_double(Krikri::MappingDSL::PropertyDeclaration,
                          :name => :my_property, :value => 'new_value')
        end

        it 'adds new property' do
          expect(mapping.properties).to include(new_declaration)
        end

        it 'deletes old property' do
          expect(mapping.properties).not_to include(declaration)
        end
      end
    end
  end

  describe '#add_child' do
    before do
      mapping.sourceResource :class => DPLA::MAP::SourceResource do
        title 'Comet in Moominland'

        creator :class => DPLA::MAP::Agent do
          label 'Tove Jansson'
        end
      end
    end

    it 'builds resource params as property value' do
      mapped = DPLA::MAP::Aggregation.new
      mapping.properties.first.to_proc.call(mapped, '')
      expect(mapped.sourceResource.first.creator.first.label)
        .to contain_exactly('Tove Jansson')
    end
  end
end
