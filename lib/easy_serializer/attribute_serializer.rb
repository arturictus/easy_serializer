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
      # Check if value is nil
      # eval option default ( in case is block)
      if value.nil?
        return metadata.get_default(object, serializer)
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

    def cache_or_attribute
      if EasySerializer.perform_caching && metadata.catch?
        CacheRef.new(serializer, metadata).execute
        # Cacher.call(serializer, metadata, nil, &metadata.get_value)
      else
        serializer.instance_exec object, &metadata.get_value
      end
    end

    def serialize!(serializer_class, value)
      return unless value
      if EasySerializer.perform_caching && metadata.catch?
        Cacher.call(serializer, metadata, value)
      else
        metadata.serialize!(value, serializer)
      end
    end
  end
end
