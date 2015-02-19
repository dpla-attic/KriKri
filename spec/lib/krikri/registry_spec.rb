require 'spec_helper'


describe Krikri::Registry do

  before(:each) do
    described_class.reset!
    described_class.register(:mock, Class.new)
    described_class.register(:another_mock, Class.new)
  end

  describe '#register' do
    it 'creates a registry entry for an item not already registered' do
      # see before block above
      expect(described_class.keys).to include :mock
    end
    it 'errors when registering a class that is already registered' do
      expect do
        described_class.register(:mock, Class.new)
      end.to raise_error 'mock is already registered.'
    end
    it 'does not error when force-registered' do
      expect do
        described_class.register!(:mock, Class.new)
      end.not_to raise_error
    end
  end

  describe '#registered?' do
    it 'knows an item has been registered' do
      expect(described_class.registered?(:mock)).to be true
    end
  end

  describe '#get' do
    it 'gets a registered item' do
      expect(described_class.get(:mock)).to be_a Class
    end
    it 'errors when unregistered' do
        expect { described_class.get('undefined') }
        .to raise_error 'undefined is not registered.'
    end
  end

  describe '#keys' do
    it 'returns an array of registered keys' do
      expect(described_class.keys).to be_a Array
    end
    it 'returns an array that contains a registered key' do
      expect(described_class.keys).to include :mock
    end
  end

  describe '#reset!' do
    it 'has no registered items' do
      described_class.reset!
      expect(described_class.keys).to be_empty
    end
  end

  describe '#unregister!' do
    it 'deletes a registry entry' do
      described_class.unregister!(:mock)
      expect(described_class.keys).not_to include :mock
    end
  end
end
