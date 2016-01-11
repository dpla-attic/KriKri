shared_examples 'an invalidatable resource' do
  describe '#invalidate!' do
    it 'raises an error' do
      expect { subject.invalidate! }
        .to raise_error('Cannot invalidate ' \
                        "#{subject.rdf_subject}, does not exist.")
    end

    it 'does not add triples' do
      expect { begin; subject.invalidate!; rescue; end }
        .not_to change { subject.rdf_source.statements.to_a }
    end

    context 'with URI subject' do
      include_context 'clear repository'
      include_context 'with RDF subject'
      
      before do
        if subject.rdf_subject.nil?
          allow(subject)
            .to receive(:rdf_subject)
                 .and_return(subject.rdf_source.rdf_subject / '.xml')
        end
      end

      it 'raises an error' do
        expect { subject.invalidate! }
          .to raise_error('Cannot invalidate ' \
                          "#{subject.rdf_subject}, does not exist.")
      end

      context 'when saved' do
        before { subject.save }

        it 'invalidates the subject' do
          expect { subject.invalidate! }.to change { subject.invalidated? }.to(true)
        end

        it 'sets prov:wasInvalidatedBy' do
          uri = RDF::URI('http://example.org/groak')

          expect { subject.invalidate!(uri) }
            .to change { subject.was_invalidated_by }.to(uri)
        end

        context 'and invalidated' do
          before { subject.invalidate! }

          it 'raises an error' do
            expect { subject.invalidate! }
              .to raise_error('Cannot invalidate ' \
                              "#{subject.rdf_subject}, already invalid.")
          end

          it 'ignores when ignore_invalid is given' do
            expect { subject.invalidate!(nil, true) }
              .not_to raise_error
          end
        end
      end
    end
  end

  describe '#invalidated?' do
    it 'gives appropriate boolean value' do
      st = [RDF::URI(subject.rdf_subject), RDF::PROV.invalidatedAtTime, DateTime.now]

      expect { subject.rdf_source << st }
        .to change { subject.invalidated? }.from(false).to(true)
    end
  end

  describe '#invalidated_at_time' do
    it 'is nil' do
      expect(subject.invalidated_at_time).to be_nil
    end

    context 'when invalidated' do
      it 'gives invalidated time' do
        time = DateTime.now
        st = [RDF::URI(subject.rdf_subject), RDF::PROV.invalidatedAtTime, time]

        expect { subject.rdf_source << st }
          .to change { subject.invalidated_at_time }.to(time)
      end
    end

    describe '#was_invalidated_by' do
      it 'gives prov:wasInvalidatedBy' do
        uri = RDF::URI('http://example.org/groak')
        st = [RDF::URI(subject.rdf_subject), RDF::PROV.wasInvalidatedBy, uri]

        expect { subject.rdf_source << st }
          .to change { subject.was_invalidated_by }.from(nil).to(uri)
      end
    end
  end
end
