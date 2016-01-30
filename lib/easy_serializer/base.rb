module EasySerializer
  class Base
    delegate :to_json, :[], to: :serialize
    attr_reader :object
    def initialize(object)
      @object = object
    end

    class << self

      def call(obj)
        new(obj).serialize
      end
      alias_method :serialize, :call
      alias_method :to_hash, :call
      alias_method :to_h, :call

      def attribute(name, opts = {}, &block)
        @__serializable_attributes ||= []
        @__serializable_attributes << { name: name, block: block }.merge(opts)
      end

      def cache(bool, opts = {}, &block)
        if bool
          @__cache = opts.merge(block: block)
        end
      end

      def attributes(*args)
        args.each do |input|
          attribute(*input)
        end
      end

      def collection(name, opts = {}, &block)
        opts = opts.merge(collection: true)
        attribute(name, opts, &block)
      end
    end

    def serialize
      @serialize ||= serialized_from_cache || _serialize
    end
    alias_method :to_h, :serialize
    alias_method :to_hash, :serialize
    alias_method :to_s, :to_json

    private

    def _serialize
      __serializable_attributes.each_with_object(HashWithIndifferentAccess.new) do |setup, hash|
        if setup[:key] === false
          hash.merge!(attr_serializer(setup))
        else
          key = (setup[:key] ? setup[:key] : setup[:name])
          hash[key] = attr_serializer(setup)
        end
      end
    end

    def serialized_from_cache
      return false unless EasySerializer.perform_caching
      cache = __cache
      return false unless cache
      if cache[:block]
        cache[:block].call(object, self)
      else
        key = if cache[:key]
          cache[:key].call(object)
        else
          [object, 'EasySerialized']
        end
        fail "[Serializer] No key for cache" unless key
        EasySerializer.cache.fetch(key) { _serialize }
      end
    end

    def __cache
      self.class.instance_variable_get(:@__cache)
    end

    def __serializable_attributes
      self.class.instance_variable_get(:@__serializable_attributes) || []
    end

    def attr_serializer(setup)
      value = cache_or_attribute(setup)
      return value unless serializer = setup[:serializer]
      if setup[:collection]
        Array.wrap(value).map { |o|  cache_or_serialize(serializer, o, setup) }
      else
        cache_or_serialize(serializer, value, setup)
      end
    end

    def cache_or_attribute(setup)
      execute = setup[:block] || proc { |o| o.send(setup[:name]) }
      if EasySerializer.perform_caching && setup[:cache] && !setup[:serializer]
        EasySerializer.cache.fetch(object, setup[:name]) do
          instance_exec object, &execute
        end
      else
        instance_exec object, &execute
      end
    end

    def cache_or_serialize(serializer, value, opts)
      return unless value
      if EasySerializer.perform_caching && opts[:cache]
        key = if opts[:cache_key]
          opts[:cache_key].call(value)
        else
          [value, 'EasySerialized']
        end
        EasySerializer.cache.fetch(key) { send_to_serializer(serializer, value) }
      else
        send_to_serializer(serializer, value)
      end
    end

    def from_setup_serializer(serializer, value)
      case serializer
      when Proc
        instance_exec value, &serializer
      else
        serializer
      end
    end

    def send_to_serializer(serializer, value)
      return unless value
      from_setup_serializer(serializer, value).call(value)
    end
  end
end
