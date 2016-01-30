require 'spec_helper'
describe 'Cache Options' do
  before do
    allow(EasySerializer).to receive(:cache).and_return(CacheMock)
    allow(EasySerializer).to receive(:perform_caching).and_return(true)
  end
  describe 'On root cache' do
    class OptionForRootCache < EasySerializer::Base
      cache true, expires_in: 10.minutes
      attribute :name
    end
    let(:obj) { OpenStruct.new(name: 'Jack Sparrow') }
    let(:execute) { OptionForRootCache.call(obj) }
    it 'cache receives the options' do
      expect(CacheMock).to receive(:fetch).with(instance_of(Array), expires_in: 10.minutes)
      execute
    end
  end
  describe 'On Attribute cache_options' do
    class OptionForAttributeCache < EasySerializer::Base
      attribute :name, cache: true, cache_options: { expires_in: 10.minutes }
    end
    let(:obj) { OpenStruct.new(name: 'Jack Sparrow') }
    let(:execute) { OptionForAttributeCache.call(obj) }
    it 'cache receives the options' do
      expect(CacheMock).to receive(:fetch).with(instance_of(Array), expires_in: 10.minutes)
      execute
    end
  end
end
