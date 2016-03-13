describe 'Cache' do
  class UserSerializer < EasySerializer::Base
    cache true
    attributes :name, :email
  end
  let(:user) { OpenStruct.new(name: 'John Doe', email: 'asdfsd@sdfsd.com') }
  let(:cache) { CacheMock }
  before do
    allow(EasySerializer).to receive(:perform_caching).and_return(true)
    allow(EasySerializer).to receive(:cache).and_return(cache)
  end

  context 'using .cache method' do
    subject do
      UserSerializer.new(user)
    end

    it 'Once cached do not calls object methods' do
      expect(user).not_to receive(:name)
      expect(user).not_to receive(:email)
      expect(subject.to_h).to eq :cached
    end

    it 'calls the cache fetch method' do
      expect(cache).to receive(:fetch).with([user, 'EasySerialized'], instance_of(Hash))
      subject.to_h
    end
  end

  context 'Cache method with key' do
    class CacheMethodWithKey < EasySerializer::Base
      cache true, key: proc { |object| [object, upcase('key_from_block')] }
      attributes :name

      def upcase str
        str.upcase
      end
    end

    it 'Once cached do not calls object methods' do
      expect(user).not_to receive(:name)
      output = CacheMethodWithKey.call(user)
      expect(output).to eq :cached
    end

    it 'call fetch with the block output' do
      expect(cache).to receive(:fetch).with([user, 'KEY_FROM_BLOCK'], instance_of(Hash)).and_call_original
      output = CacheMethodWithKey.call(user)
      expect(output).to eq :cached
    end

  end

  context 'using cache option' do
    class CompanySerializer < EasySerializer::Base
      attribute :name
      collection :users, cache: true, serializer: UserSerializer
      attribute :contact, cache: true, serializer: UserSerializer
    end
    let(:contact) { OpenStruct.new(name: 'Jane Smith', email: 'asdfsd@sdfsd.com') }
    let(:company) { OpenStruct.new(name: 'Company Name', users: [user], contact: contact) }

    subject do
      CompanySerializer.new(company)
    end

    it 'calls the cache fetch method on collection and on attribute' do
      expect(cache).to receive(:fetch).with([user, 'EasySerialized'], instance_of(Hash))
      expect(cache).to receive(:fetch).with([contact, 'EasySerialized'], instance_of(Hash))
      subject.to_h
    end

    it 'Once cached do not calls object methods' do
      expect(user).not_to receive(:name)
      expect(contact).not_to receive(:name)
      expect(subject.to_h[:users]).to eq [:cached]
      expect(subject.to_h[:contact]).to eq :cached
    end
  end

  describe 'Cache Blocks' do
    describe 'chache_key block' do
      class CacheKeyExample < EasySerializer::Base
        attribute :name, cache: true, cache_key: proc { 'my_key' }
      end
      let(:cache) { CacheMock }
      let(:obj) { OpenStruct.new(name: 'hello') }
      before do
        allow(EasySerializer).to receive(:perform_caching).and_return(true)
        allow(EasySerializer).to receive(:cache).and_return(cache)
        expect(cache).to receive(:fetch).with('my_key', instance_of(Hash))
      end
      let(:execute) { CacheKeyExample.call(obj) }
      it { execute }
      it 'once cached does not call to object methods' do
        expect(obj).not_to receive(:name)
        execute
      end
    end
  end
end
