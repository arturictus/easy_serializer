module EasySerializer
  Cacher = Struct.new(:serializer) do
    include Helpers

    def self.call(serializer, metadata, value, &block)
      Cacher.new(serializer)
        .set(options: metadata.options, block: block, value: value)
        .execute
    end

    def self.root_call(serializer, options, value, &block)
      options[:cache_key] = options[:key]
      options[:root_call] = true
      metadata = OpenStruct.new(options: options)
      call(serializer, metadata, value, &block)
    end

    attr_accessor :object, :options, :block
    attr_writer :value

    delegate :object, to: :serializer

    def set(options)
      options.each { |k, v| send("#{k}=", v) }
      self
    end

    def value
      return unless object && block
      @value ||= serializer.instance_exec object, &block
    end

    def key(_value = nil)
      _value ||= value
      @key ||= if options[:cache_key]
                 option_to_value(options[:cache_key], _value, serializer)
               elsif options[:serializer] || options[:root_call]
                 [_value, 'EasySerialized'].flatten
               else
                 [_value, options[:name], 'EasySerialized'].flatten
               end
    end

    def options_for_cache
      if options[:root_call]
        options.except(:block, :cache_key, :root_call, :serializer, :key)
      else
        options[:cache_options]
      end || {}
    end

    def _block_to_execute(_value = nil)
      _value ||= value
      if options[:serializer]
        proc { serializer.send_to_serializer(options[:serializer], _value) }
      else
        proc { serializer.instance_exec object, &block }
      end
    end

    def fetch(_key = nil, _value = nil)
      _key ||= key
      _value ||= value
      EasySerializer.cache.fetch(_key, options_for_cache, &_block_to_execute(_value))
    end

    def wrap(elem)
      CacheOutput.new(elem)
    end

    def execute
      elem = if options[:collection]
        Array.wrap(value).map{ |o| fetch(key(o), o) }
      else
        fetch
      end
      wrap(elem)
    end
  end
end
