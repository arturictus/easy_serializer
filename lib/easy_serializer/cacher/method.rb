module EasySerializer
  class Cacher
    class Method < Template

      def execute
        fetch
      end

      def key
        cache_key = if metadata.cache_key
                      option_to_value(metadata.cache_key, serializer.object, serializer)
                    else
                      metadata.name
                    end
        [serializer.object, cache_key, serializer.class.name].flatten
      end

      def options
        metadata.cache_options || {}
      end

      def block_to_get_value
        proc { serializer.instance_exec serializer.object, &metadata.get_value }
      end

      def fetch
        EasySerializer.cache.fetch(key, options, &block_to_get_value)
      end
    end
  end
end
