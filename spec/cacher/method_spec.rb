module EasySerializer
  describe Cacher::Method do
    let(:metadata) { Attribute.new(:name, {}, nil) }
    let(:object) { Contextuable.new(name: 'John', random: rand(100)) }
    let(:serializer) { Base.new(object) }
    subject do
      described_class.new(serializer, metadata)
    end

    describe '#key' do
      context 'default' do
        it { expect(subject.key).to include(:name) }
        it { expect(subject.key).to include(object) }
        it { expect(subject.key).to include(serializer.class.name) }
        it do
          allow(EasySerializer).to receive(:cache).and_return(CacheMock)
          expect(EasySerializer.cache).to receive(:fetch).with(subject.key, any_args)
          subject.execute
        end
      end

      context 'setting cache_key' do
        context 'inline' do
          let(:metadata) { Attribute.new(:name, { cache_key: 'my_cache_key' }, nil) }
          it { expect(subject.key).to include('my_cache_key') }
          it { expect(subject.key).to include(serializer.class.name) }
          it { expect(subject.key).to include(object) }
        end
        context 'block' do
          let(:metadata) do
            Attribute.new(:name,
              { cache_key: proc { object.random } },
              nil)
          end
          it { expect(subject.key).to include(object.random) }
          it { expect(subject.key).to include(serializer.class.name) }
          it { expect(subject.key).to include(object) }
        end
      end
    end

    describe '#options' do
      let(:cache_options) { { expires_at: '3.days.from_now' } }
      context 'When options are set' do
        let(:metadata) do
          Attribute.new(:name, { cache_options: cache_options }, nil)
        end
        it { expect(subject.options).to eq cache_options }
        it do
          allow(EasySerializer).to receive(:cache).and_return(CacheMock)
          expect(EasySerializer.cache).to receive(:fetch).with(subject.key, cache_options, any_args)
          subject.execute
        end
      end

      context 'When options are set' do
        it { expect(subject.options).to eq({}) }
      end

    end

    describe 'Returning the spected value' do
      before do
        allow(EasySerializer).to receive(:cache).and_return(CacheMockExplicid)
      end
      it 'output' do
        expect(subject.execute).to eq 'John'
      end
    end
    describe 'Verifing cache' do
      before do
        allow(EasySerializer).to receive(:cache).and_return(CacheMock)
        expect(object).not_to receive(:name)
      end
      it 'output' do
        expect(subject.execute).to eq :cached
      end
    end

    describe 'passing block' do
      let(:block) { proc { |object| object.name.upcase } }
      let(:metadata) { Attribute.new(:name, {}, block) }
      describe 'Returning the spected value' do
        before do
          allow(EasySerializer).to receive(:cache).and_return(CacheMockExplicid)
        end
        it 'output' do
          expect(subject.execute).to eq 'JOHN'
        end
      end
      describe 'Verifing cache' do
        before do
          allow(EasySerializer).to receive(:cache).and_return(CacheMock)
          expect(object).not_to receive(:name)
        end
        it 'output' do
          expect(subject.execute).to eq :cached
        end
      end
    end
  end
end
