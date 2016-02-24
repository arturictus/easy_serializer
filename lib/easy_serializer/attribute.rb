module EasySerializer
  Attribute = Struct.new(:serializer, :setup) do
    include Helpers
    def self.call(serializer, setup)
      new(serializer, setup).value
    end

    def object
      serializer.object
    end
    def value
      value_or_default
    end

    def value_or_default
      value = attr_serializer
      if value.nil? && setup[:default]
        return option_to_value(setup[:default], object, serializer)
      end
      value
    end

    def attr_serializer
      value = cache_or_attribute
      return value.output if value.is_a?(CacheOutput)
      return value unless serializer_class = setup[:serializer]
      if setup[:collection]
        Array.wrap(value).map { |o| serialize!(serializer_class, o) }
      else
        serialize!(serializer_class, value)
      end
    end
    def send_name(obj)
      obj.send(setup[:name])
    end

    def cache_or_attribute
      execute = setup[:block] || method(:send_name)
      if EasySerializer.perform_caching && setup[:cache]
        # catch!(true, value, execute)
        Cacher.call(serializer, setup, nil, &execute)
      else
        serializer.instance_exec object, &execute
      end
    end

    def send_to_serializer(serializer_class, value)
      return unless value
      option_to_value(serializer_class, value, serializer).call(value)
    end

    def catch!(attribute, value, block)
      return unless EasySerializer.perform_caching && setup[:cache]
      if attribute
        Cacher.call(serializer, setup, nil, &block)
      else
        Cacher.call(serializer, setup, value)
      end
    end

    def serialize!(serializer_class, value)
      return unless value
      if EasySerializer.perform_caching && setup[:cache]
        # catch!(false, value)
        Cacher.call(serializer, setup, value)
      else
        send_to_serializer(serializer_class, value)
      end
    end
  end
end
