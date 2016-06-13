require 'spec_helper'
require 'krikri/spec/harvester'

describe Krikri::Harvesters::PrimoHarvester do
  let(:args) do
    {
      uri: 'http://example.org/endpoint',
      id_minter: Krikri::Md5Minter,
      primo: {
        bulk_size: bulk_size
      }
    }
  end

  let(:bulk_size) { 10 }

  let(:fake_response) do
    <<eos
    <sear:SEGMENTS xmlns:sear="http://www.exlibrisgroup.com/xsd/jaguar/search">
  <sear:JAGROOT>
    <sear:RESULT>
      <sear:DOCSET HIT_TIME="38" TOTALHITS="23" FIRSTHIT="1"
           LASTHIT="1" TOTAL_TIME="112" IS_LOCAL="true">
        <sear:DOC ID="999" RANK="1.0" NO="1"
                  SEARCH_ENGINE="Local Search Engine"
                  SEARCH_ENGINE_TYPE="Local Search Engine">
          <PrimoNMBib
            xmlns="http://www.exlibrisgroup.com/xsd/primo/primo_nm_bib">
            <record>
              <control>
                <sourcerecordid>1234</sourcerecordid>
                <sourceid>GETTY_ROSETTA</sourceid>
                <recordid>GETTY_ROSETTA1234</recordid>
                <sourceformat>DC</sourceformat>
                <sourcesystem>Other</sourcesystem>
              </control>
              <display>
                <type>digital_entity</type>
                <title>a title</title>
              </display>
            </record>
          </PrimoNMBib>
        </sear:DOC>
      </sear:DOCSET>
    </sear:RESULT>
  </sear:JAGROOT>
</sear:SEGMENTS>
eos
  end

  subject { described_class.new(args) }

  context 'record fetching' do
    before(:each) do
      stub_request(:get, 'http://example.org/endpoint?bulkSize=1&indx=1')
        .to_return(:status => 200, :body => fake_response)
    end

    it 'can determine a record count' do
      expect(subject.count).to eq(23)
    end

    it 'fetches records across multiple pages' do
      [1, 11, 21].each do |index|
        stub_request(:get,
                     "http://example.org/endpoint?bulkSize=10&indx=#{index}")
          .to_return(:status => 200, :body => fake_response)
      end

      records = subject.records.to_a

      expect(records.length).to eq(3)
    end

    context 'large bulk size parameter' do
      let(:bulk_size) { 1000 }

      it 'honors the :bulk_size parameter' do
        stub_request(:get, 'http://example.org/endpoint?bulkSize=1000&indx=1')
          .to_return(:status => 200, :body => fake_response)

        subject.records.to_a
      end
    end

    it 'throws an exception if the server returns an error' do
      stub_request(:get, 'http://example.org/endpoint?bulkSize=10&indx=1')
        .to_return(:status => 200, :body => fake_response)

      stub_request(:get, 'http://example.org/endpoint?bulkSize=10&indx=11')
        .to_return(:status => 500, :body => 'Uh oh')

      expect { subject.records.to_a }
        .to raise_error(Krikri::Harvesters::PrimoHarvester::PrimoHarvestError)
    end

    it 'can search a single record by identifier' do
      stub_request(:get, 'http://example.org/endpoint?' \
                         'bulkSize=1' \
                         '&indx=1' \
                         '&query=rid,exact,GETTY_ROSETTA1234')
        .to_return(:status => 200, :body => fake_response)

      record = subject.get_record('GETTY_ROSETTA1234')

      expect(record.local_name)
        .to eq(Krikri::Md5Minter.create('GETTY_ROSETTA1234'))
    end

    it 'retries timed out requests' do
      expect_any_instance_of(Faraday::Adapter::NetHttp)
        .to receive(:perform_request)
        .at_least(4).times
        .and_raise(Net::ReadTimeout.new)
      expect { subject.records.first }
        .to raise_error(Faraday::TimeoutError)
    end
  end
end
