class PolymophicSubjectSerializer < EasySerializer::Base
  attribute :nested, serializer: NestedSerializer
  collection :collection, serializer: NestedSerializer
  attribute :record_locator
  attribute :seat
  attribute :confirmation_number
end
