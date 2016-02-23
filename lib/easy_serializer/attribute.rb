module EasySerializer
  Attribute = Struct.new(:serializer, :setup) do
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
        return option_to_value(setup[:default], object)
      end
      value
    end

    def attr_serializer
      value = cache_or_attribute
      return value if value.respond_to?(:fetch) || value.respond_to?(:each)
      return value unless serializer = setup[:serializer]
      if setup[:collection]
        Array.wrap(value).map { |o| cache_or_serialize(serializer, o, setup) }
      else
        cache_or_serialize(serializer, value, setup)
      end
    end

    def cache_or_attribute
      execute = setup[:block] || proc { |o| o.send(setup[:name]) }
      if EasySerializer.perform_caching && setup[:cache]
        Cacher.call(self, setup, nil, &execute)
      else
        if object.respond_to?(:each)
          object.map { |o| serializer.instance_exec o, &execute }
        else
          serializer.instance_exec object, &execute
        end
      end
    end

    def send_to_serializer(serializer, value)
      return unless value
      option_to_value(serializer, value).call(value)
    end

    def cache_or_serialize(serializer, value, opts)
      return unless value
      if EasySerializer.perform_caching && opts[:cache]
        Cacher.call(self, opts, value)
      else
        send_to_serializer(serializer, value)
      end
    end
  end
end
