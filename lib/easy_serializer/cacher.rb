module EasySerializer
  Cacher = Struct.new(:serializer) do
    include Helpers

    def self.call(serializer, options, value, &block)
      Cacher.new(serializer)
        .set(options: options, block: block, value: value)
        .execute
    end

    def self.root_call(serializer, options, value, &block)
      call(serializer, options, value, &block)
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


    def key
      @key ||= if options.cache_key
                 option_to_value(options.cache_key, value, serializer)
               elsif options.serializer? || options.root_call?
                 [value, 'EasySerialized'].flatten
               else
                 [value, options.name, 'EasySerialized'].flatten
               end
    end

    def execute
      to_execute = if options.serializer?
                     proc { serializer.send_to_serializer(options.serializer, value) }
                   else
                     proc { serializer.instance_exec object, &block }
                   end
      EasySerializer.cache.fetch(key, options.cache_options, &to_execute)
    end
  end
end
