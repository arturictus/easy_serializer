module EasySerializer
  class Cacher
    class Serializer
      attr_reader :cacher
      delegate :serializer, :metadata, to: :cacher
      def initialize(cacher)
        @cacher = cacher
      end

      def execute
        fetch(key, options)
      end

      def key(_value = nil)
        _value ||= value
        @key ||= [_value, 'EasySerialized'].flatten
      end

      def options
        metadata.cache_options
      end

      def block_to_get_value
        proc { metadata.serialize!(serializer.object, serializer) }
      end

      def value
        serializer.instance_exec serializer.object, &metadata.get_value
      end

      def nested_serializer
        metadata.serializer(serializer.object, serializer)
      end

      def fetch(_key = nil, _value = nil)
        _key ||= key
        _value ||= value
        EasySerializer.cache.fetch(_key, options, &block_to_get_value)
      end
    end
  end
end
