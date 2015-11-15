class PolymophicSubject
  def initialize
    {
      nested: OpenStruct.new(name: 'my name', id: rand(999)),
      collection: [OpenStruct.new(name: 'my name', id: rand(999))],
      record_locator: 'ajsdlf',
      seat: 'B12',
      confirmation_number: '198374'
    }.each do |k, v|
      define_singleton_method(k){ v }
    end
  end
end
