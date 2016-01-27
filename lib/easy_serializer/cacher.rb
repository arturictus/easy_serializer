module EasySerializer
  Cacher = Struct.new(:serializer) do
    include Helpers

    def self.call(serializer, options, value, &block)
      cacher = Cacher.new(serializer)
      cacher.set(options: options, block: block, value: value)
      cacher.execute
    end

    def self.root_call(serializer, options, value, &block)
      options[:cache_key] = options[:key]
      options[:root_call] = true
      call(serializer, options, value, &block)
    end

    attr_accessor :object, :options, :block
    attr_writer :value

    delegate :object, to: :serializer

    def set(options)
      options.each { |k, v| send("#{k}=", v) }
    end

    def value
      return unless object && block
      @value ||= serializer.instance_exec object, &block
    end


    def key
      @key ||= if options[:cache_key]
                 option_to_value(options[:cache_key], value, serializer)
               elsif options[:serializer] || options[:root_call]
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
