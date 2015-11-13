require 'spec_helper'
describe PolymorphicSerializer do
  let(:attrs) do
    {
      id: '123',
      date: Date.today
      subject: PolymophicSubject.new
    }
  end
  let(:object) { OpenStruct.new(attrs) }
  let(:instance) { described_class.new(object) }
  describe '#serialized' do
    subject {  }
  end

end
