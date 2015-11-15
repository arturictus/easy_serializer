require 'spec_helper'
[
  "./spec/support/serializers/nested_serializer.rb",
  "./spec/support/serializers/polymorphic_subject.rb",
  "./spec/support/serializers/polymorphic_subject_serializer.rb",
  "./spec/support/serializers/polymophic_serializer.rb"
].each{ |f| require f }

describe PolymorphicSerializer do
  let(:attrs) do
    {
      id: '123',
      date: Date.today,
      subject: PolymophicSubject.new,
      subject_type: 'PolymophicSubject',
      subject_id: '5783'
    }
  end
  let(:object) { OpenStruct.new(attrs) }
  let(:instance) { described_class.new(object) }
  describe '#serialized' do
    subject { instance.to_h }
    it { expect(subject[:segment_type]).to eq object.subject_type }
    it { expect(subject[:segment_id]).to eq object.id }
    it { expect(subject[:date]).to eq object.date }
    context 'key: false, includes object keys at same level' do
      it { expect(subject[:date]).to eq object.date }
      it { expect(subject).to have_key('collection') }
      it { expect(subject).to have_key('nested') }
      it { expect(subject[:record_locator]).to eq object.subject.record_locator }
      it { expect(subject[:seat]).to eq object.subject.seat }
      it { expect(subject[:confirmation_number]).to eq object.subject.confirmation_number }
    end
    describe 'serializer: [Constant] nested objects with specified serilizer' do
      it { expect(subject[:nested][:id]).to eq object.subject.nested.id }
      it { expect(subject[:nested][:name]).to eq object.subject.nested.name }
      describe 'collection' do
        it { expect(subject[:collection][0][:id]).to eq object.subject.collection.first.id }
        it { expect(subject[:collection][0][:name]).to eq object.subject.collection.first.name }
      end
    end
  end

end
