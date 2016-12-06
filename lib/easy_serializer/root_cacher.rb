module EasySerializer
  class RootCacher
    include Helpers

    def self.call(serializer, &block)
      new(serializer, &block).execute
    end

    attr_reader :serializer, :block
    def initialize(serializer, &block)
      @serializer = serializer
      @block = block
    end

    def execute
      fetch
    end

    def object
      serializer.object
    end

    def options
      serializer.__cache.except(:block, :cache_key, :root_call, :serializer, :key)
    end

    def key
      custom_key = serializer.__cache[:key]
      if custom_key
        k = option_to_value(custom_key, object, serializer)
        [object, k, serializer.class.name]
      else
        [object, serializer.class.name]
      end.flatten
    end

    def fetch
      EasySerializer.cache.fetch(key, options, &block)
    end

  end
end
