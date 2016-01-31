describe 'default values when nil' do
  context 'As a literal' do
    class DefaultLiteral < EasySerializer::Base
      attribute :name
      attribute :boolean, default: true
      attribute :missing, default: 'anything'
    end
    let(:execute) { DefaultLiteral.call(obj) }
    context 'nil values' do
      let(:obj) { OpenStruct.new(name: 'Jack', boolean: nil, missing: nil) }
      it { expect(execute.fetch(:name)).to eq 'Jack' }
      it { expect(execute.fetch(:boolean)).to eq true }
      it { expect(execute.fetch(:missing)).to eq 'anything' }
    end
    context 'With values' do
      let(:obj) { OpenStruct.new(name: 'Jack', boolean: false, missing: 'blabla') }
      it { expect(execute.fetch(:name)).to eq 'Jack' }
      it { expect(execute.fetch(:boolean)).to eq false }
      it { expect(execute.fetch(:missing)).to eq 'blabla' }
    end
  end
  context 'As a Proc' do
    class DefaultProc < EasySerializer::Base
      attribute :name
      attribute :boolean, default: proc { |obj| obj.name == 'Jack' }
      attribute :missing, default: proc { |obj| "#{obj.name}-missing" }
    end

    let(:execute) { DefaultProc.call(obj) }

    context 'nil values' do
      let(:obj) { OpenStruct.new(name: 'Jack', boolean: nil, missing: nil) }
      it { expect(execute.fetch(:name)).to eq 'Jack' }
      it { expect(execute.fetch(:boolean)).to eq true }
      it { expect(execute.fetch(:missing)).to eq 'Jack-missing' }
    end
    context 'With values' do
      let(:obj) { OpenStruct.new(name: 'Jack', boolean: false, missing: 'blabla') }
      it { expect(execute.fetch(:name)).to eq 'Jack' }
      it { expect(execute.fetch(:boolean)).to eq false }
      it { expect(execute.fetch(:missing)).to eq 'blabla' }
    end
  end
  context 'When blocks are the value output' do
    context 'As Proc' do
      class DefaultWithBlockProc < EasySerializer::Base
        attribute :name
        attribute :boolean, default: proc { |obj| obj.name == 'Jack' } do |obj|
          obj.boolean
        end
        attribute :missing, default: proc { |obj| "#{obj.name}-missing" } do |obj|
          obj.missing
        end
      end

      let(:execute) { DefaultWithBlockProc.call(obj) }

      context 'nil values' do
        let(:obj) { OpenStruct.new(name: 'Jack', boolean: nil, missing: nil) }
        it { expect(execute.fetch(:name)).to eq 'Jack' }
        it { expect(execute.fetch(:boolean)).to eq true }
        it { expect(execute.fetch(:missing)).to eq 'Jack-missing' }
      end
      context 'With values' do
        let(:obj) { OpenStruct.new(name: 'Jack', boolean: false, missing: 'blabla') }
        it { expect(execute.fetch(:name)).to eq 'Jack' }
        it { expect(execute.fetch(:boolean)).to eq false }
        it { expect(execute.fetch(:missing)).to eq 'blabla' }
      end
    end
    context 'As a literal' do
      class DefaultBlockLiteral < EasySerializer::Base
        attribute :name
        attribute :boolean, default: true do |obj|
          obj.boolean
        end
        attribute :missing, default: 'anything' do |obj|
          obj.missing
        end
      end
      let(:execute) { DefaultBlockLiteral.call(obj) }
      context 'nil values' do
        let(:obj) { OpenStruct.new(name: 'Jack', boolean: nil, missing: nil) }
        it { expect(execute.fetch(:name)).to eq 'Jack' }
        it { expect(execute.fetch(:boolean)).to eq true }
        it { expect(execute.fetch(:missing)).to eq 'anything' }
      end
      context 'With values' do
        let(:obj) { OpenStruct.new(name: 'Jack', boolean: false, missing: 'blabla') }
        it { expect(execute.fetch(:name)).to eq 'Jack' }
        it { expect(execute.fetch(:boolean)).to eq false }
        it { expect(execute.fetch(:missing)).to eq 'blabla' }
      end
    end
  end
end
