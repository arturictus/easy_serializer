module EasySerializer
  Cacher = Struct.new(:serializer, :object, :options, :block, :value) do
    include Helpers

    def self.call(serializer, object, options, block, value)
      new(serializer, object, options, block, value).execute
    end

    def execute
      key = if options[:cache_key]
        option_to_value(options[:cache_key], value)
      else
        [value, 'EasySerialized']
      end
      if options[:serializer] && options[:cache_key]
        # binding.pry
        EasySerializer.cache.fetch(key) { serializer.send_to_serializer(options[:serializer], value) }
      elsif !options[:serializer]
        EasySerializer.cache.fetch(object, options[:name]) do
          serializer.instance_exec object, &block
        end
      elsif options[:serializer]
        EasySerializer.cache.fetch(key) { serializer.send_to_serializer(options[:serializer], value) }
      end

    end
  end
end
