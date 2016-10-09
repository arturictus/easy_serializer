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
      custom = serializer.__cache[:key]
      if custom
        option_to_value(custom, object, serializer)
      else
        [object, 'EasySerialized'].flatten
      end
    end

    def fetch
      EasySerializer.cache.fetch(key, options, &block)
    end

  end
end
