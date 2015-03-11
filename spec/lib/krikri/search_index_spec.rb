require 'spec_helper'

describe Krikri::QASearchIndex do
  let(:solr) { RSolr.connect }

  describe '#initialize' do
    context 'with args' do
      subject { described_class.new(opts) }
      let(:opts) { { url: 'http://my-client-uri/' } }

      it 'passes options to RSolr client' do
        expect(subject.solr.uri.to_s).to eq opts[:url]
      end
    end

    it 'defaults to Krikri::Settings.solr' do
      uri = 'http://moomin.org/'
      allow(Krikri::Settings)
        .to receive(:solr).and_return(url: uri)
      expect(subject.solr.uri.to_s).to eq uri
    end
  end

  describe '#solr_doc' do
    context 'without models' do
      before :each do
        fake_schema_keys = ['a', 'b', 'c', 'b_c', 'b_d']
        allow(subject).to receive(:schema_keys).and_return(fake_schema_keys)
      end

      it 'converts JSON into Solr-compatible hash' do
        json = { 'a' => '1', 'b' => { 'c' => '2', 'd' => '3' } }.to_json
        flat_hash = { 'a' => '1', 'b_c' => '2', 'b_d' => '3' }
        expect(subject.solr_doc(json)).to eq flat_hash
      end

      it 'removes special character strings from keys' do
        json = {
          'http://www.geonames.org/ontology#a' => '1',
          'http://www.w3.org/2003/01/geo/wgs84_pos#b' => '2',
          '@c' => '3'
        }.to_json
        flat_hash = { 'a' => '1', 'b' => '2', 'c' => '3' }
        expect(subject.solr_doc(json)).to eq flat_hash
      end

      it 'removes keys that are not in solr schema' do
        json = { 'a' => '1', 'invalid_key' => '0' }.to_json
        valid_hash = { 'a' => '1' }
        expect(subject.solr_doc(json)).to eq valid_hash
      end
    end

    context 'with models' do
      include_context 'provenance queries'
      include_context 'generated entities query'

      # generator_uri matches what Krikri::Activity will construct as the
      # uri, given its value of #rdf_subject, in #aggregations_as_json
      # See 'provenance queries' shared context.
      #
      # FIXME:  See the activities factory for generator_uri,
      #         spec/factories/krikri_activities.rb.  This generator URI would
      #         ideally be for ID 3.
      let(:generator_uri) { 'http://localhost:8983/marmotta/ldp/activity/1' }

      let(:activity) do
        a = build(:krikri_activity)
        a.id = 1
        a
      end

      before do
        aggregation.set_subject!('http://api.dp.la/item/123')
        subject.add aggregation.to_jsonld['@graph'][0].to_json
        subject.commit
      end

      after do
        q = 'id:*'
        subject.delete_by_query(q)
        subject.commit
      end

      it 'posts DPLA MAP JSON to solr' do
        response = solr.get('select', :params => { :q => '' })['response']
        expect(response['numFound']).to eq 1
      end

      it 'updates records affected by an activity' do
        expect do
          subject.update_from_activity(activity)
        end.to_not raise_error
      end
    end

    describe '#schema_keys' do
      it 'returns an Array of keys' do
        result = subject.schema_keys
        expect(result).to be_a(Array)
        expect(result).not_to be_empty
      end
    end
  end
end


describe Krikri::ProdSearchIndex do
  context 'with arguments to #initialize' do
    describe '#initialize' do
      let(:opts) { {} }
      subject { described_class.new(opts) }
    end
  end
end
