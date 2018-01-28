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
      return value unless metadata.nested_serializer?
      if metadata.is_a? Collection
        ary = value.is_a?(Array) ? value : (value == nil ? [] : [value])
        ary.map { |o| nested_serialization!(o) }
      else
        nested_serialization!(value)
      end
    end

    def cache_or_attribute
      if EasySerializer.perform_caching && metadata.catch?
        Cacher.new(serializer, metadata).execute
      else
        serializer.instance_exec object, &metadata.get_value
      end
    end

    def nested_serialization!(value)
      return unless value
      metadata.serialize!(value, serializer)
    end
  end
end
