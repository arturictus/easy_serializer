require 'spec_helper'

class SimpleSerializer < EasySerializer::Base
  attribute :name
end

describe SimpleSerializer do
  let(:object) { OpenStruct.new(name: 'Artur') }
  let(:call) { SimpleSerializer.call(object) }
  it { expect(call.fetch(:name)).to eq 'Artur' }

end
