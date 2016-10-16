module EasySerializer
  class Cacher
    class Template
      include Helpers
      attr_reader :serializer, :metadata

      def initialize(serializer, metadata)
        @serializer = serializer
        @metadata = metadata
      end

      def self.call(*args)
        new(*args).execute
      end

      private

      def metadata_key
        return @metadata_key if defined?(@metadata_key)
        @metadata_key = if metadata.cache_key
          option_to_value(metadata.cache_key, serializer.object, serializer)
        end
      end
    end
  end
end
