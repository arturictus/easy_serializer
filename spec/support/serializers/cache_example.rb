require 'support/serializers/nested_serializer'
class CacheWholeExample < EasySerializer::Base
  cache true
  attribute :name
end
class CacheNestedExample < EasySerializer::Base
  attribute :nested, serializer: NestedSerializer, cache: true
end
class CacheMethodExample < EasySerializer::Base
  attribute :some_method
end
