require 'support/serializers/cache_examples'
describe 'cache Examples' do
  before do
    allow(EasySerializer).to receive(:cache).and_return(CacheMock)
    allow(EasySerializer).to receive(:perform_caching).and_return(true)
  end
  describe CacheWholeExample do
    let(:obj) { OpenStruct.new(name: 'Rio de Janeiro') }
    let(:serialized) { described_class.call(obj) }
    it { expect{ serialized }.not_to raise_error }
    it { expect(serialized).to eq(:cached) }
  end
  describe CacheNestedExample do
    let(:obj) do
      OpenStruct.new(
        name: 'Rio de Janeiro',
        nested: OpenStruct.new(id: 1, name: 'some name')
      )
    end
    let(:serialized) { described_class.call(obj) }
    it { expect{ serialized }.not_to raise_error }
    it { expect(serialized.fetch(:nested)).to eq(:cached) }
    it { expect(serialized.fetch(:name)).to eq(obj.name) }
  end
  describe CacheMethodExample do
    let(:obj) do
      OpenStruct.new(costly: 'really long processing method')
    end
    let(:serialized) { described_class.call(obj) }
    it { expect{ serialized }.not_to raise_error }
    it { expect(serialized.fetch(:costly)).to eq(:cached) }
    context 'cache returning the content' do
      let(:my_cache) { CacheMockExplicid }
      before do
        allow(EasySerializer).to receive(:cache).and_return(my_cache)
        expect(my_cache).to receive(:fetch).and_call_original
      end
      it { expect(serialized.fetch(:costly)).to eq(obj.costly) }
    end
  end
  describe CacheBlockExample do
    let(:obj) do
      OpenStruct.new(costly: 'really long processing method')
    end
    let(:serialized) { described_class.call(obj) }
    it { expect{ serialized }.not_to raise_error }
    it { expect(serialized.fetch(:costly)).to eq(:cached) }
    context 'cache returning the content' do
      let(:my_cache) { CacheMockExplicid }
      before do
        allow(EasySerializer).to receive(:cache).and_return(my_cache)
        expect(my_cache).to receive(:fetch).and_call_original
      end
      it { expect(serialized.fetch(:costly)).to eq(obj.costly) }
    end
  end

end
