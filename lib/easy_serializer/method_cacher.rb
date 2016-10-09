module EasySerializer
  class MethodCacher
    attr_reader :cacher
    delegate :serializer, :metadata, to: :cacher
    def initialize(cacher)
      @cacher = cacher
    end

    def execute
      fetch(key, options)
    end

    def key(_value = nil)
      @key ||= [_value, metadata.options[:name], 'EasySerialized'].flatten
    end

    def options
      metadata.cache_options || {}
    end

    def block_to_get_value
      proc { serializer.instance_exec serializer.object, &metadata.get_value }
    end

    def fetch(_key = nil, _value = nil)
      _key ||= key
      _value ||= value
      EasySerializer.cache.fetch(_key, options, &block_to_get_value)
    end
  end
end
