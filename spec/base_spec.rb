describe NestedSerializer do
  let(:obj) { OpenStruct.new(id: 1, name: 'name') }
  describe '::call' do
    let(:execute) { described_class.call(obj) }
    it { expect(execute.fetch(:id)).to eq 1 }
    it { expect(execute.fetch(:name)).to eq 'name' }
    it 'has alias `::serialize`' do
      expect(described_class.method(:call)).to eq described_class.method(:serialize)
    end
    it 'has alias `::to_hash`' do
      expect(described_class.method(:call)).to eq described_class.method(:to_hash)
    end
    it 'has alias `::to_h`' do
      expect(described_class.method(:call)).to eq described_class.method(:to_h)
    end
  end
end
