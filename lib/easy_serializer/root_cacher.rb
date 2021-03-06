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
    alias_method :subject, :object

    def cache_key
      return object.cache_key if object.respond_to?(:cache_key)
      object
    end

    def options
      h = serializer.__cache.dup
      [:block, :cache_key, :root_call, :serializer, :key].each do |k|
        h.delete(k)
      end
      h
    end

    def key
      custom_key = serializer.__cache[:key]
      if custom_key
        k = option_to_value(custom_key, object, serializer)
        [cache_key, k, serializer.class.name]
      else
        [cache_key, serializer.class.name]
      end.flatten
    end

    def fetch
      EasySerializer.cache.fetch(key, options, &block)
    end

  end
end
