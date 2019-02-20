module EasySerializer
  class Cacher
    class Serializer < Template

      def execute
        fetch
      end

      def key
        if metadata_key
          [cache_key, metadata_key, nested_serializer.name]
        else
          [cache_key, nested_serializer.name]
        end.flatten
      end

      def subject
        value
      end

      def options
        metadata.cache_options || {}
      end

      def block_to_get_value
        proc { metadata.serialize!(value, serializer) }
      end

      def value
        serializer.instance_exec serializer.object, &metadata.get_value
      end

      def nested_serializer
        metadata.serializer(serializer.object, serializer)
      end

      def fetch
        EasySerializer.cache.fetch(key, options, &block_to_get_value)
      end
    end
  end
end
