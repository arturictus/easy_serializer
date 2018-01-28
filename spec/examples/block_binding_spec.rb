describe 'Block Binding' do
  class BlocksBinding < EasySerializer::Base
    attribute :name do |object|
      upcase object.name
    end

    def upcase(str)
      str.upcase
    end
  end

  describe 'Block to get attributes values' do
    let(:obj) { OpenStruct.new(name: 'rigoverto') }
    let(:result) { BlocksBinding.call(obj) }
    it { expect(result.fetch(:name)).to eq obj.name.upcase }
  end

  describe 'Blocks in serializer option' do
    describe 'Dynamic Serializer' do
      class DynamicSerializer < EasySerializer::Base
        attribute :thing, serializer: proc { dynamic }
        attribute :d_name

        def dynamic
          BlocksBinding
        end
      end
      let(:thing) { OpenStruct.new(name: 'rigoverto') }
      let(:obj) { OpenStruct.new(d_name: 'a name', thing: thing) }
      let(:result) { DynamicSerializer.call(obj) }
      it { expect(result.fetch(:thing).fetch(:name)).to eq thing.name.upcase }
      it { expect(result.fetch(:d_name)).to eq obj.d_name }
    end

    describe 'Dynamic Serializer using value inside block' do
      class DynamicWithContentSerializer < EasySerializer::Base
        attribute :thing, serializer: proc { |value| to_const value.serializer }
        attribute :d_name

        def to_const(str)
          BlocksBinding
        end
      end
      let(:thing) { OpenStruct.new(name: 'rigoverto', serializer: 'BlocksBinding') }
      let(:obj) { OpenStruct.new(d_name: 'a name', thing: thing) }
      let(:result) { DynamicWithContentSerializer.call(obj) }
      it { expect(result.fetch(:thing).fetch(:name)).to eq thing.name.upcase }
      it { expect(result.fetch(:d_name)).to eq obj.d_name }
    end
    # describe 'Passing a block for serialization' do
    #   class DynamicWithBlockAsSerializer < EasySerializer::Base
    #     attribute :thing, serializer: proc { |value| {}[:name] = value.name }
    #     attribute :d_name
    #   end
    #   let(:thing) { OpenStruct.new(name: 'rigoverto', serializer: 'BlocksBinding') }
    #   let(:obj) { OpenStruct.new(d_name: 'a name', thing: thing) }
    #   let(:result) { DynamicWithBlockAsSerializer.call(obj) }
    #   it { expect(result.fetch(:thing).fetch(:name)).to eq thing.name.upcase }
    #   it { expect(result.fetch(:d_name)).to eq obj.d_name }
    # end
  end

end
