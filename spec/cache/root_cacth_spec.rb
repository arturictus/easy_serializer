require 'spec_helper'

describe 'RootCaching' do
  class NameSerializer < EasySerializer::Base
    cache true
    attribute :name
  end
  class RootCaching < EasySerializer::Base
    cache true
    attribute :name, serializer: NameSerializer, cache: true, key: false
    collection :names, serializer: NameSerializer, cache: true
  end
  let(:root) do
    root = Struct.new(:name, :names)
    root.new(name, [name])
  end
  let(:name) do
    name = Struct.new(:name)
    name.new(:hello)
  end
  before do
    allow(EasySerializer).to receive(:cache).and_return(CacheMockExplicid)
  end
  subject { RootCaching.call(root) }
  it { expect{ subject }.not_to raise_error }

end
