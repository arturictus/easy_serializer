require 'support/serializers/cache_example'
describe 'cache' do
  before do
    allow(EasySerializer).to receive(:cache).and_return(CacheMock)
    allow(EasySerializer).to receive(:perform_caching).and_return(true)
  end
  describe CacheWholeExample do
    let(:obj) { OpenStruct.new(name: 'Rio de Janeiro') }
    let(:serialized) { described_class.new(obj).serialize }
    it { expect{ serialized }.not_to raise_error }
    it { expect(serialized).to eq(:cached) }
  end

end
