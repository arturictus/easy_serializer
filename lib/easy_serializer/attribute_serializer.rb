module EasySerializer
  AttributeSerializer = Struct.new(:serializer, :metadata) do
    include Helpers
    def self.call(serializer, metadata)
      new(serializer, metadata).value
    end

    def object
      serializer.object
    end
    def value
      value_or_default
    end

    def value_or_default
      value = attr_serializer
      if value.nil? && metadata.options[:default]
        return option_to_value(metadata.options[:default], object, serializer)
      end
      value
    end

    def attr_serializer
      value = cache_or_attribute
      return value.output if value.is_a?(CacheOutput)
      return value unless serializer_class = metadata.options[:serializer]
      if metadata.is_a? Collection
        Array.wrap(value).map { |o| serialize!(serializer_class, o) }
      else
        serialize!(serializer_class, value)
      end
    end

    def send_name(obj)
      obj.send(metadata.name)
    end

    def cache_or_attribute
      execute = metadata.block || method(:send_name)
      if EasySerializer.perform_caching && metadata.options[:cache]
        Cacher.call(serializer, metadata, nil, &execute)
      else
        serializer.instance_exec object, &execute
      end
    end

    def send_to_serializer(serializer_class, value)
      return unless value
      option_to_value(serializer_class, value, serializer).call(value)
    end

    def serialize!(serializer_class, value)
      return unless value
      if EasySerializer.perform_caching && metadata.options[:cache]
        Cacher.call(serializer, metadata, value)
      else
        send_to_serializer(serializer_class, value)
      end
    end
  end
end
