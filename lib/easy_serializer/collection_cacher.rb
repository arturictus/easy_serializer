module EasySerializer
  class CollectionCacher
    attr_reader :cacher
    delegate :serializer, :metadata, to: :cacher
    def initialize(cacher)
      @cacher = cacher
    end

    def execute
      collection.map do |elem|
        fetch(key(elem), elem)
      end
    end

    def collection
      @collection ||= serializer.instance_exec serializer.object, &metadata.get_value
    end

    def key(elem)
      [elem, 'EasySerialized'].flatten
    end

    def options
      metadata.cache_options || {}
    end

    def block_to_get_value(elem)
      proc { nested_serializer.call(elem) }
    end

    def nested_serializer
      metadata.serializer(serializer.object, serializer)
    end

    def fetch(key, elem)
      EasySerializer.cache.fetch(key, options, &block_to_get_value(elem))
    end
  end
end
