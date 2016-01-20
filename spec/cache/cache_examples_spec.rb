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
  end

end
