module EasySerializer
  Cacher = Struct.new(:serializer, :object, :options, :block, :value) do
    include Helpers

    def self.call(serializer, object, options, block, value)
      new(serializer, object, options, block, value).execute
    end

    def initialize(*args)
      super
      if value.nil?
        self.value = serializer.instance_exec object, &block
      end
    end

    def key
      @key ||= if options[:cache_key]
                 option_to_value(options[:cache_key], value)
               elsif options[:serializer]
                 [value, 'EasySerialized'].flatten
               else
                 [value, options[:name], 'EasySerialized'].flatten
               end
    end

    def execute
      to_execute = if options[:serializer]
        proc { serializer.send_to_serializer(options[:serializer], value) }
      elsif !options[:serializer]
        proc { serializer.instance_exec object, &block }
      end
      EasySerializer.cache.fetch(key, &to_execute)
    end
  end
end
