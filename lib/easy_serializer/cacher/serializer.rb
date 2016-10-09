module EasySerializer
  class Cacher
    class Serializer < Template

      def execute
        fetch
      end

      private

      def key
        # TODO check key
        [value, 'EasySerialized'].flatten
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

      def fetch
        EasySerializer.cache.fetch(key, options, &block_to_get_value)
      end
    end
  end
end
