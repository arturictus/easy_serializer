class CacheWholeExample < EasySerializer::Base
  cache true
  attribute :name
end
class CacheNestedExample < EasySerializer::Base
  attribute :name
  attribute :nested, serializer: NestedSerializer, cache: true
end
class CacheMethodExample < EasySerializer::Base
  attribute :costly, cache: true
end
class CacheBlockExample < EasySerializer::Base
  attribute :costly, cache: true do |obj|
    obj.costly
  end
end
