# -*- coding: utf-8 -*-
require 'spec_helper'
require 'pry'

describe Krikri::Harvesters::CouchdbHarvester do

  let(:args) { { uri: 'http://example.org:5984/couchdb' } }
  # Generic Analysand view response for all records.  Note that we're using a
  # ViewResponse when it could be a StreamingViewResponse in some cases.  The
  # interfaces of these classes is the same, so it keeps these tests cleaner to
  # stick to ViewResponse.
  let(:view_response) { double(Analysand::ViewResponse) }
  # Analysand view responses for paginated requests that are used in `#records'
  let(:view_response_page_1) { double(Analysand::ViewResponse) }
  let(:view_response_page_2) { double(Analysand::ViewResponse) }

  # The HTTP response bodies from the view responses above, plus the options
  # passed in the corresponding client.view calls
  #
  let(:view_response_body) do
    <<-EOS.strip_heredoc
{"total_rows":5,"offset":0,"rows":[
{"id":"10046--http://ark.cdlib.org/ark:/13030/kt009nc254","key":"10046--http://ark.cdlib.org/ark:/13030/kt009nc254","value":{"rev":"11-e68fd829f55b85dec51d044fe4711530"},"doc":{"_id":"10046--http://ark.cdlib.org/ark:/13030/kt009nc254","_rev":"11-e68fd829f55b85dec51d044fe4711530","object":"e6d7a72d8e957175a46965f104b9bb52"}},
{"id":"10046--http://ark.cdlib.org/ark:/13030/kt0199p9ph","key":"10046--http://ark.cdlib.org/ark:/13030/kt0199p9ph","value":{"rev":"11-fec45c2c32bf6b468d8d6413796ff85b"},"doc":{"_id":"10046--http://ark.cdlib.org/ark:/13030/kt0199p9ph","_rev":"11-fec45c2c32bf6b468d8d6413796ff85b","object":"744cc17058614440ae6c3722aaacb4c3"}},
{"id":"10046--http://ark.cdlib.org/ark:/13030/kt029016nn","key":"10046--http://ark.cdlib.org/ark:/13030/kt029016nn","value":{"rev":"11-b3e9a75b56599a78cb875ffb5c508c2b"},"doc":{"_id":"10046--http://ark.cdlib.org/ark:/13030/kt029016nn","_rev":"11-b3e9a75b56599a78cb875ffb5c508c2b","object":"bfecb6c11db808ca6603cd13def5f9bf"}},
{"id":"10046--http://ark.cdlib.org/ark:/13030/kt038nc34r","key":"10046--http://ark.cdlib.org/ark:/13030/kt038nc34r","value":{"rev":"11-c9ebbeb8064280e674ea79c0b16c59d6"},"doc":{"_id":"10046--http://ark.cdlib.org/ark:/13030/kt038nc34r","_rev":"11-c9ebbeb8064280e674ea79c0b16c59d6","object":"d2e3b4d91fba4f77df6fb8fab46f3375"}},
{"id":"10046--http://ark.cdlib.org/ark:/13030/kt0489p9km","key":"10046--http://ark.cdlib.org/ark:/13030/kt0489p9km","value":{"rev":"11-7fbb604516852656d30f37bbe1f09d5f"},"doc":{"_id":"10046--http://ark.cdlib.org/ark:/13030/kt0489p9km","_rev":"11-7fbb604516852656d30f37bbe1f09d5f","object":"0162e70cde3d9d77ba8cbe9e146beda4"}}
]}
EOS
  end

  let(:view_opts_page_1) do
    {include_docs: true, stream: false, limit: 4, startkey: '0'}
  end
  let(:view_response_body_page_1) do
    <<-EOS.strip_heredoc
{"total_rows":4,"offset":0,"rows":[
{"id":"10046--http://ark.cdlib.org/ark:/13030/kt009nc254","key":"10046--http://ark.cdlib.org/ark:/13030/kt009nc254","value":{"rev":"11-e68fd829f55b85dec51d044fe4711530"},"doc":{"_id":"10046--http://ark.cdlib.org/ark:/13030/kt009nc254","_rev":"11-e68fd829f55b85dec51d044fe4711530","object":"e6d7a72d8e957175a46965f104b9bb52"}},
{"id":"10046--http://ark.cdlib.org/ark:/13030/kt0199p9ph","key":"10046--http://ark.cdlib.org/ark:/13030/kt0199p9ph","value":{"rev":"11-fec45c2c32bf6b468d8d6413796ff85b"},"doc":{"_id":"10046--http://ark.cdlib.org/ark:/13030/kt0199p9ph","_rev":"11-fec45c2c32bf6b468d8d6413796ff85b","object":"744cc17058614440ae6c3722aaacb4c3"}},
{"id":"10046--http://ark.cdlib.org/ark:/13030/kt029016nn","key":"10046--http://ark.cdlib.org/ark:/13030/kt029016nn","value":{"rev":"11-b3e9a75b56599a78cb875ffb5c508c2b"},"doc":{"_id":"10046--http://ark.cdlib.org/ark:/13030/kt029016nn","_rev":"11-b3e9a75b56599a78cb875ffb5c508c2b","object":"bfecb6c11db808ca6603cd13def5f9bf"}},
{"id":"10046--http://ark.cdlib.org/ark:/13030/kt038nc34r","key":"10046--http://ark.cdlib.org/ark:/13030/kt038nc34r","value":{"rev":"11-c9ebbeb8064280e674ea79c0b16c59d6"},"doc":{"_id":"10046--http://ark.cdlib.org/ark:/13030/kt038nc34r","_rev":"11-c9ebbeb8064280e674ea79c0b16c59d6","object":"d2e3b4d91fba4f77df6fb8fab46f3375"}}
]}
EOS
  end

  let(:view_opts_page_2) do
    { include_docs: true, stream: false, limit: 4,
      startkey: '10046--http://ark.cdlib.org/ark:/13030/kt038nc34r0' }
  end
  let(:view_response_body_page_2) do
    <<-EOS.strip_heredoc
{"total_rows":1,"offset":0,"rows":[
{"id":"10046--http://ark.cdlib.org/ark:/13030/kt0489p9km","key":"10046--http://ark.cdlib.org/ark:/13030/kt0489p9km","value":{"rev":"11-7fbb604516852656d30f37bbe1f09d5f"},"doc":{"_id":"10046--http://ark.cdlib.org/ark:/13030/kt0489p9km","_rev":"11-7fbb604516852656d30f37bbe1f09d5f","object":"0162e70cde3d9d77ba8cbe9e146beda4"}}
]}
EOS
  end

  let(:view_opts_common_stream) { { include_docs: false, stream: true } }
  let(:view_opts_common_nostream) do
    { include_docs: true, stream: false, limit: 10, startkey: '0'}
  end

  let(:document_response) do
    <<-EOS.strip_heredoc
{"_id":"10046--http://ark.cdlib.org/ark:/13030/kt009nc254","_rev":"11-e68fd829f55b85dec51d044fe4711530","object":"e6d7a72d8e957175a46965f104b9bb52"}
EOS
  end

  let(:identifier) { '10046--http://ark.cdlib.org/ark:/13030/kt009nc254' }

  let(:parsed_response) { JSON.parse(view_response_body) }
  let(:parsed_response_page_1) { JSON.parse(view_response_body_page_1) }
  let(:parsed_response_page_2) { JSON.parse(view_response_body_page_2) }

  before do
    allow(view_response).to receive(:docs)
      .and_return(parsed_response['rows'].map { |r| r['doc'] })
    allow(view_response).to receive(:keys)
      .and_return(parsed_response['rows'].map { |r| r['key'] })
    allow(view_response).to receive(:total_rows)
      .and_return(parsed_response['total_rows'])

    allow(view_response_page_1).to receive(:docs)
      .and_return(parsed_response_page_1['rows'].map { |r| r['doc'] })
    allow(view_response_page_2).to receive(:docs)
      .and_return(parsed_response_page_2['rows'].map { |r| r['doc'] })
  end

  subject { described_class.new(args) }

  it 'has a client' do
    expect(subject.client).to be_a Analysand::Database
  end

  context 'with connection' do

    before do
      stub_request(:get, "http://example.org:5984/couchdb/#{CGI.escape(identifier)}")
        .with(:headers => {
          'Accept'=>'*/*',
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3'})
        .to_return(:status => 200, :body => document_response, :headers => {})
    end

    describe 'options' do
      let(:result) { double }

      let(:args) do
        { uri: 'http://example.org:5984/couchdb',
          couchdb: { view: '_all_docs' } }
      end

      # "send options" shared example takes these options:
      #
      # `method`: method to test
      # `m_opts`: options passed into the given method
      # `r_opts`: options that should be passed to client.view for the request,
      #           given the method opts
      # `default_r_opts`: default options that should be used for client.view
      #           given no options from the caller
      #
      shared_examples 'send options' do |ex_opts|
        before do
          allow(subject.client).to receive(:view).and_return view_response
          allow(view_response).to receive(:keys).and_return []
          allow(view_response).to receive(:total_rows).and_return 0
        end
        it 'sends request with correct default options' do
          records = subject.send(ex_opts[:method])
          records.first if ex_opts[:method] == :records  # start enumerator
          expect(subject.client).to have_received(:view)
            .with('_all_docs', ex_opts[:default_r_opts])
        end

        it 'adds options passed into request' do
          records = subject.send(ex_opts[:method], ex_opts[:m_opts])
          records.first if ex_opts[:method] == :records  # start enumerator
          expect(subject.client).to have_received(:view)
            .with(ex_opts[:m_opts][:view], ex_opts[:r_opts])
        end
      end

      describe '#count' do
        default_request_opts = {limit: 0, include_docs: false, stream: true}
        include_examples 'send options', method: :count,
                                         m_opts: {view: 'foo/bar'},
                                         r_opts: default_request_opts,
                                         default_r_opts: default_request_opts
      end

      describe '#records' do
        before do
          allow(Krikri::OriginalRecord).to receive(:build)
            .and_return instance_double(Krikri::OriginalRecord)
        end

        default_request_opts = {
          include_docs: true, stream: false, limit: 10, startkey: '0'
        }
        request_opts = {
          include_docs: true, stream: false, limit: 5, startkey: '0'
        }
        include_examples 'send options', method: :records,
                                         m_opts: {view: 'foo/bar', limit: 5},
                                         r_opts: request_opts,
                                         default_r_opts: default_request_opts

        it 'iterates over paginated requests' do
          # See the view_opts_page_* and related mocks above.
          # given those, the call to #records with a limit of 4 will make two
          # Analysand::Database.view calls and return 5 records.
          expect(subject.client).to receive(:view)
            .with(instance_of(String), view_opts_page_1)
            .and_return(view_response_page_1)
          expect(subject.client).to receive(:view)
            .with(instance_of(String), view_opts_page_2)
            .and_return(view_response_page_2)
          recs = subject.records(limit: 4)
          expect(recs.count).to eq 5
        end
      end

      describe '#record_ids' do
        default_request_opts = { :include_docs=>false, :stream=>true }
        include_examples 'send options', method: :record_ids,
                                         m_opts: {view: 'foo/bar'},
                                         r_opts: default_request_opts,
                                         default_r_opts: default_request_opts
      end
    end

    describe "#get_record" do
      let(:resp) { double(Analysand::Response) }

      before do
        allow(resp).to receive(:body)
          .and_return(JSON.parse(document_response))
        allow(subject.client).to receive(:get!)
          .with(instance_of(String)).and_return(resp)
      end

      it 'requests the record by identifier' do
        resp = subject.get_record(identifier)
        expect(subject.client).to have_received(:get!)
          .with(CGI.escape(identifier))
      end
    end

    describe '#enqueue' do
      let(:args) do
        { uri: 'http://example.org:5984/couchdb',
          couchdb: { view: '_all_docs' } }
      end

      before do
        Resque.remove_queue('harvest')  # Not strictly necessary. Future?
        Krikri::Activity.delete_all
      end

      it 'saves harvest options correctly when creating an activity' do
        # Ascertain that options particular to this harvester type are
        # serialized and deserialized properly.
        described_class.enqueue(args)
        activity = Krikri::Activity.first
        opts = JSON.parse(activity.opts, symbolize_names: true)
        expect(opts).to eq(args)
      end
    end

    context do
      before do
        allow(subject.client).to receive(:view).and_return view_response
      end
      it_behaves_like 'a harvester'
    end
  end
end

describe Krikri::Harvester::Registry do
  describe '#registered?' do
    it 'knows CouchdbHarvester is registered' do
      # It should have been registered by the engine initializer, engine.rb.
      expect(described_class.registered?(:couchdb)).to be true
    end
  end
end
