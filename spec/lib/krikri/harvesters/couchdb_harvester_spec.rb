# -*- coding: utf-8 -*-
require 'spec_helper'
require 'pry'

describe Krikri::Harvesters::CouchdbHarvester do

  let(:args) { { uri: 'http://example.org:5984/couchdb' } }
  let(:svr) { double(Analysand::StreamingViewResponse) }

  # Set up some responses to reuse
  let(:view_response) do
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

  let(:document_response) do
    <<-EOS.strip_heredoc
{"_id":"10046--http://ark.cdlib.org/ark:/13030/kt009nc254","_rev":"11-e68fd829f55b85dec51d044fe4711530","object":"e6d7a72d8e957175a46965f104b9bb52"}
EOS
  end

  let(:parsed_response) { JSON.parse(view_response) }

  before do
    allow(svr).to receive(:docs)
      .and_return(parsed_response['rows'].map { |r| r['doc'] })
    allow(svr).to receive(:keys)
      .and_return(parsed_response['rows'].map { |r| r['key'] })
    allow(svr).to receive(:total_rows)
      .and_return(parsed_response['total_rows'])
    allow(subject.client).to receive(:view)
      .with(instance_of(String), instance_of(Hash)).and_return(svr)
  end

  subject { described_class.new(args) }

  it 'has a client' do
    expect(subject.client).to be_a Analysand::Database
  end

  context 'with connection' do
    describe 'options' do
      let(:result) { double }

      let(:args) do
        { uri: 'http://example.org:5984/couchdb',
          couchdb: { view: '_all_docs' } }
      end

      let(:request_opts) { { view: 'foo/bar' } }

      shared_examples 'send options' do
        it 'sends request with option' do
          result = subject.send(method)
          result.first if [:records, :record_ids].include? method
          expect(subject.client).to have_received(request_type)
            .with(args[:couchdb][:view], hash_including(view_args))
        end

        it 'adds options passed into request' do
          result = subject.send(method, request_opts)
          result.first if [:records, :record_ids].include? method
          expect(subject.client).to have_received(request_type)
            .with(request_opts[:view], hash_including(view_args))
        end
      end

      describe '#count' do
        include_examples 'send options'
        let(:request_type) { :view }
        let(:method) { :count }
        let(:view_args) { { :limit => 0, :include_docs=>false, :stream=>true } }
      end

      describe '#records' do
        include_examples 'send options'
        let(:request_type) { :view }
        let(:method) { :records }
        let(:view_args) { { :include_docs=>true, :stream=>true } }
      end

      describe '#record_ids' do
        include_examples 'send options'
        let(:request_type) { :view }
        let(:method) { :record_ids }
        let(:view_args) { { :include_docs=>false, :stream=>true } }
      end

      describe '#get_record' do
        include_examples 'send options'
        let(:request_type) { :view }
        let(:method) { :count }
        let(:view_args) { { :include_docs=>false, :stream=>true } }
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
        described_class.enqueue(Krikri::HarvestJob, args)
        activity = Krikri::Activity.first
        opts = JSON.parse(activity.opts, symbolize_names: true)
        expect(opts).to eq(args)
      end
    end

    it_behaves_like 'a harvester'
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
