require 'spec_helper'

describe Krikri::Mapper::Agent do
  before(:all) do
    create(:krikri_mapping_activity)
    create(:krikri_harvest_activity)
  end

  harvest_gen_uri_str = \
    (RDF::URI(Krikri::Settings['marmotta']['ldp']) /
    Krikri::Settings['prov']['activity'] / '2').to_s

  mapping_gen_uri_str = \
    (RDF::URI(Krikri::Settings['marmotta']['ldp']) /
    Krikri::Settings['prov']['activity'] / '3').to_s

  # This must be defined with `let' as a macro.  See below.
  let(:opts) { {name: :agent_map, generator_uri: harvest_gen_uri_str} }

  # This can not be a macro, because it has to be passed as an argument to
  # `it_behaves_like', which is interpreted at compile time.  It should be the
  # same as the hash returned by :opts above.
  #
  # As a further note, rspec executes any examples that might come
  # below in random order.  Since `subject' is a macro that is executed
  # every time `subject' is referenced below, `described_class.new' gets
  # invoked each time.  If there is a method (as there is) that deletes hash
  # keys from `opts' (supposing it's a hash like `behaves_opts' instead of a
  # macro), then `subject' will not instantiate an object with the same options
  # when it's invoked repeatedly.
  # 
  behaves_opts = {name: :agent_map, generator_uri: harvest_gen_uri_str}
  it_behaves_like 'a software agent', behaves_opts

  subject { described_class.new(opts) }

  # See spec/factories/krikri_activities.rb
  # generator_uri is the URI of the harvest activity
  # generator_uri matches what Krikri::Activity will construct as the
  # uri, given its value of #rdf_subject, in #aggregations_as_json
  # See 'provenance queries' shared context.  
  let(:generator_uri) { harvest_gen_uri_str }

  # activity_uri is the URI of the mapping activity
  let(:activity_uri) { mapping_gen_uri_str }

  let(:mapping_name) { :agent_map }
  let(:opts) { { name: mapping_name, generator_uri: generator_uri } }

  describe '::queue_name' do
    it { expect(described_class.queue_name.to_s).to eq 'mapping' }
  end

  describe '#run' do
    let(:agg_record_double) { instance_double(DPLA::MAP::Aggregation) }
    let(:generated_records) do
      [agg_record_double, agg_record_double.clone, agg_record_double.clone]
    end

    before do
      allow(subject.generator_activity).to receive(:generated_entities)
        .and_return([:record1, :record2])  #  why not generated_records above?
      allow(agg_record_double).to receive(:node?).and_return(true)
      allow(agg_record_double).to receive(:mint_id!)
      allow(agg_record_double).to receive(:save)
    end

    context 'with errors thrown' do
      before do
        allow(agg_record_double).to receive(:node?).and_raise(StandardError.new)
        allow(agg_record_double).to receive(:rdf_subject).and_return('123')
        allow(Krikri::Mapper).to receive(:map).and_return(generated_records)
      end

      it 'logs errors' do
        expect(Rails.logger).to receive(:error)
                                 .with(start_with('Error saving record: 123'))
                                 .exactly(3).times
        subject.run(activity_uri)
      end
    end

    context 'with mapped records returned' do
      before do
        expect(Krikri::Mapper).to receive(:map)
                                   .with(mapping_name, subject.generator_activity.generated_entities)
                                   .and_return(generated_records)
      end

      it 'calls mapper' do
        subject.run
      end

      it 'sets generator' do
        generated_records.each do |rec|
          statement = double
          allow(RDF).to receive(:Statement)
                         .with(rec, RDF::PROV.wasGeneratedBy, activity_uri)
                         .and_return(statement)
          expect(rec).to receive(:<<).with(statement)
        end
        subject.run(activity_uri)
      end
    end
  end

end
