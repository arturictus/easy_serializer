require 'spec_helper'
module EasySerializer
  describe Cacher::Serializer do
    class OSerializer < EasySerializer::Base
      attribute :name
    end
    let(:metadata) { Attribute.new(:user, { serializer: OSerializer }, nil) }
    let(:user) { Contextuable.new(name: 'John', random: rand(100)) }
    let(:object) { Contextuable.new(user: user) }
    let(:serializer) { Base.new(object) }
    subject do
      described_class.new(serializer, metadata)
    end

    describe '#value' do
      it { expect(subject.value).to eq user }
    end
    describe '#key' do
      context 'default' do
        # it { expect(subject.key).to include(:user) }
        it { expect(subject.key).to include(user) }
        it { expect(subject.key).to include(OSerializer.name) }
        it do
          allow(EasySerializer).to receive(:cache).and_return(CacheMock)
          expect(EasySerializer.cache).to receive(:fetch).with(subject.key, any_args)
          subject.execute
        end
      end

      context 'setting cache_key' do
        context 'inline' do
          let(:metadata) { Attribute.new(:user, { cache_key: 'my_cache_key', serializer: OSerializer }, nil) }
          it { expect(subject.key).to include('my_cache_key') }
          it { expect(subject.key).to include(user) }
          it { expect(subject.key).to include(OSerializer.name) }
        end
        context 'block' do
          let(:metadata) do
            Attribute.new(:user,
              { cache_key: proc { object.user.random }, serializer: OSerializer },
              nil)
          end
          it { expect(subject.key).to include(object.user.random) }
          it { expect(subject.key).to include(user) }
          it { expect(subject.key).to include(OSerializer.name) }
        end
      end
    end

    describe '#options' do
      let(:cache_options) { { expires_at: '3.days.from_now' } }
      context 'When options are set' do
        let(:metadata) do
          Attribute.new(:user, { cache_options: cache_options, serializer: OSerializer }, nil)
        end
        it { expect(subject.options).to eq cache_options }
        it do
          allow(EasySerializer).to receive(:cache).and_return(CacheMock)
          expect(EasySerializer.cache).to receive(:fetch).with(subject.key, cache_options, any_args)
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
        expect(subject.execute).to eq({name: 'John'})
      end
    end
    describe 'Verifing cache' do
      before do
        allow(EasySerializer).to receive(:cache).and_return(CacheMock)
        expect(user).not_to receive(:name)
      end
      it 'output' do
        expect(subject.execute).to eq :cached
      end
    end

    describe 'passing block' do
      let(:block) { proc { |object| object.user } }
      let(:metadata) { Attribute.new(:name, {serializer: OSerializer}, block) }
      describe 'Returning the spected value' do
        before do
          allow(EasySerializer).to receive(:cache).and_return(CacheMockExplicid)
        end
        it 'output' do
          expect(subject.execute).to eq({name: 'John'})
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
