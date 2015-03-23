shared_examples 'an LDP RDFSource' do
  it_behaves_like 'an LDP Resource'

  include_context 'clear repository'

  error_msg = "#{described_class} requires a URI rdf_subject, but got a node."

  let(:subject_uri) { File.join(Krikri::Settings['marmotta']['ldp'], 'rdfsrc') }

  it 'is an ActiveTriples::Resource' do
    expect(subject).to be_a ActiveTriples::Resource
  end

  shared_context 'with RDF statements' do
    before do
      statements.each { |s| subject << s }
    end

    let(:statements) do
      [RDF::Statement(subject, RDF::DC.title, 'My Resource'),
       RDF::Statement(subject, RDF::DC.date, Date.today)]
    end
  end

  shared_examples 'LDP rdf_subject errors' do |method, msg|
    it 'raises error' do
      expect { subject.send(method) }.to raise_error msg
    end
  end

  describe '#save' do
    context 'without subject' do
      include_examples 'LDP rdf_subject errors', :save, error_msg
    end

    context 'with subject' do
      include_context 'with RDF subject'
      include_context 'with RDF statements'

      it "persists the graph's statements" do
        subject.save
        statements.each do |statement|
          expect(subject.statements).to include statement
        end
      end
    end
  end

  describe '#save_with_provenance' do
    include_context 'with RDF subject'

    let(:activity_uri) { RDF::URI 'http://example.org/act' }

    it 'adds generated provenance triple' do
      subject.save_with_provenance(activity_uri)
      expect(subject.query([subject, RDF::PROV.wasGeneratedBy, activity_uri]))
        .not_to be_empty
    end

    context 'when saved' do
      before { subject.save }

      it 'adds provenance triple' do
        subject.save_with_provenance(activity_uri)
        expect(subject.query([subject, RDF::DPLA.wasRevisedBy, activity_uri]))
          .not_to be_empty
      end
    end
  end

  describe '#get' do
    context 'without subject' do
      include_examples 'LDP rdf_subject errors', :get, error_msg
    end

    context 'with subject' do
      include_context 'with RDF subject'

      before do
        subject.save
      end

      include_context 'with RDF statements'

      context 'before saving new data' do
        it 'reloads initial graph' do
          subject.get
          statements.each { |s| expect(subject.statements).not_to include s }
        end
      end

      context 'after saving new data' do
        before { subject.save }

        it 'retains added triples' do
          subject.get
          statements.each { |s| expect(subject.statements).to include s }
        end
      end
    end
  end
end
