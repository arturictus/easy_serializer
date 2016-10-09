module EasySerializer
  class Cacher
    class Collection < Template

      def execute
        collection.map do |elem|
          fetch(key(elem), elem)
        end
      end

      def collection
        @collection ||= serializer.instance_exec serializer.object, &metadata.get_value
      end

      def key(elem)
        # TODO check key
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
end
