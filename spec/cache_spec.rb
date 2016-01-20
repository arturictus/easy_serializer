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
    it 'calls the cache fetch method' do
      expect(cache).to receive(:fetch).with([user, 'EasySerialized'])
      subject.to_h
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
      expect(cache).to receive(:fetch).with([user, 'EasySerialized'])
      expect(cache).to receive(:fetch).with([contact, 'EasySerialized'])
      subject.to_h
    end
  end

end
