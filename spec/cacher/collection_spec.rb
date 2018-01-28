require 'spec_helper'
module EasySerializer
  describe Cacher::Collection do
    class OSerializer < EasySerializer::Base
      attribute :name
    end
    let(:metadata) { EasySerializer::Collection.new(:user, { serializer: OSerializer }, nil) }
    let(:user) { Dystruct.new(name: 'John', random: rand(100)) }
    let(:object) { Dystruct.new(user: [user]) }
    let(:serializer) { Base.new(object) }
    subject do
      described_class.new(serializer, metadata)
    end

    describe '#value' do
      it { expect(subject.collection).to eq [user] }
    end
    describe '#key' do
      context 'default' do
        # it { expect(subject.key(user)).to include(:user) }
        it { expect(subject.key(user)).to include(user) }
        it { expect(subject.key(user)).to include(OSerializer.name) }
        it do
          allow(EasySerializer).to receive(:cache).and_return(CacheMock)
          expect(EasySerializer.cache).to receive(:fetch).with(subject.key(user), any_args)
          subject.execute
        end
      end

      context 'setting cache_key' do
        context 'inline' do
          let(:metadata) { EasySerializer::Collection.new(:user, { cache_key: 'my_cache_key', serializer: OSerializer }, nil) }
          it { expect(subject.key(user)).to include('my_cache_key') }
          it { expect(subject.key(user)).to include(user) }
          it { expect(subject.key(user)).to include(OSerializer.name) }
        end
        context 'block' do
          let(:metadata) do
            EasySerializer::Collection.new(:user,
              { cache_key: proc { object.user.first.random }, serializer: OSerializer },
              nil)
          end
          it { expect(subject.key(user)).to include(object.user.first.random) }
          it { expect(subject.key(user)).to include(user) }
          it { expect(subject.key(user)).to include(OSerializer.name) }
        end
      end
    end

    describe '#options' do
      let(:cache_options) { { expires_at: '3.days.from_now' } }
      context 'When options are set' do
        let(:metadata) do
          EasySerializer::Collection.new(:user, { cache_options: cache_options, serializer: OSerializer }, nil)
        end
        it { expect(subject.options).to eq cache_options }
        it do
          allow(EasySerializer).to receive(:cache).and_return(CacheMock)
          expect(EasySerializer.cache).to receive(:fetch).with(subject.key(user), cache_options, any_args)
          subject.execute
        end
      end

      context 'When NOT options are set' do
        it { expect(subject.options).to eq({}) }
      end

    end

    describe 'Returning the spected value' do
      before do
        allow(EasySerializer).to receive(:cache).and_return(CacheMockExplicid)
      end
      it 'output' do
        expect(subject.execute).to eq([{name: 'John'}])
      end
    end
    describe 'Verifing cache' do
      before do
        allow(EasySerializer).to receive(:cache).and_return(CacheMock)
        expect(user).not_to receive(:name)
      end
      it 'output' do
        expect(subject.execute).to eq [:cached]
      end
    end

    describe 'passing block' do
      let(:block) { proc { |object| object.user } }
      let(:metadata) { EasySerializer::Collection.new(:name, {serializer: OSerializer}, block) }
      describe 'Returning the spected value' do
        before do
          allow(EasySerializer).to receive(:cache).and_return(CacheMockExplicid)
        end
        it 'output' do
          expect(subject.execute).to eq([{name: 'John'}])
        end
      end
      describe 'Verifing cache' do
        before do
          allow(EasySerializer).to receive(:cache).and_return(CacheMock)
          expect(object).not_to receive(:name)
        end
        it 'output' do
          expect(subject.execute).to eq [:cached]
        end
      end
    end
  end
end
