class CollectionSerializer < EasySerializer::Base
  attribute :id do |object|
    "#{object.class}/#{rand(1278)}"
  end
  attribute :nested, serializer: Pathify::NestedSerializer, cache: true
  attribute :collection, serializer: Pathify::CollectionSerializer, cache: true
  attribute :record_locator, key: :booking_number
  attribute :confirmation_number do |object|
    object.provider_confirmation_number || object.booking_confirmation_number
  end
  attribute :seat
end
