module EasySerializer
  Field = Struct.new(:name, :options, :block) do
    include Helpers

    def get_value
      if block
        block
      else
        method(:send_method)
      end
    end

    def send_method(obj)
      obj.send(name)
    end

    def catch?
      options[:cache]
    end

    def serializer?
      options[:serializer]
    end

    def serializer(object, serializer_instance)
      return @serializer if defined? @serializer
      return unless serializer?
      @serializer = option_to_value(options[:serializer], object, serializer_instance)
    end

    # Important!!! DO NOT memoize this method
    def serialize!(object, serializer_instance)
      serializer = serializer(object, serializer_instance)
      return unless serializer
      serializer.call(object)
    end
  end
end
