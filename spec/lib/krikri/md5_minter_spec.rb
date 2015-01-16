require 'spec_helper'

describe Krikri::Md5Minter do
  describe '#create' do
    let(:ids) do
      [{ source: 'nypl',
         id: '5e66b3e8-fb4b-d471-e040-e00a180654d7',
         result: 'a87d1e31a525df9d3bde91e8320e908d' },
       { source: 'getty',
         id: 'GETTY_ROSETTAIE167555',
         result: 'ad9543cb337d32c7e24675fee6cb9b7a' }
      ]
    end

    it 'matches legacy identifier' do
      ids.each do |item_id|
        expect(described_class.create(item_id[:id], item_id[:source]))
          .to eq item_id[:result]
      end
    end

    it 'mints without prefix' do
      expect(described_class.create(ids.first[:id]))
        .to eq '5485b7d867192c9a0acd49f73e5f3282'
    end

    it 'mints with symbol prefix' do
      expect(described_class.create(ids.first[:id], ids.first[:source].to_sym))
        .to eq ids.first[:result]
    end
  end
end
