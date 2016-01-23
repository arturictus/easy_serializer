describe 'Block Binding' do
  class BlocksBinding < EasySerializer::Base
    attribute :name do |object|
      upcase object.name
    end

    def upcase(str)
      str.upcase
    end
  end

  class DynamicSerializer < EasySerializer::Base
    attribute :thing, serializer: proc { dynamic }
    attribute :d_name

    def dynamic
      BlocksBinding
    end
  end

  describe 'Block to get attributes values' do
    let(:obj) { OpenStruct.new(name: 'rigoverto') }
    let(:result) { BlocksBinding.call(obj) }
    it { expect(result.fetch(:name)).to eq obj.name.upcase }
  end


  describe 'Dynamic Serializer' do
    let(:thing) { OpenStruct.new(name: 'rigoverto') }
    let(:obj) { OpenStruct.new(d_name: 'a name', thing: thing) }
    let(:result) { DynamicSerializer.call(obj) }
    it { expect(result.fetch(:thing).fetch(:name)).to eq thing.name.upcase }
    it { expect(result.fetch(:d_name)).to eq obj.d_name }
  end
end
