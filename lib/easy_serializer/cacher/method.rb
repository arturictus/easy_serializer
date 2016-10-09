module EasySerializer
  class Cacher
    class Method < Template

      def execute
        fetch
      end

      def key
        # TODO check key
        [metadata.options[:name], 'EasySerialized'].flatten
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
