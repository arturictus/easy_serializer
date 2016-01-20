module EasySerializer
  class Base
    delegate :to_json, :[], to: :serialize
    attr_reader :klass_ins
    def initialize(klass_ins)
      @klass_ins = klass_ins
    end

    class << self

      def call(obj)
        new(obj).serialize
      end

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
      __serializable_attributes.each_with_object(HashWithIndifferentAccess.new) do |setup, object|
        if setup[:key] === false
          object.merge!(attr_serializer(setup))
        else
          key = (setup[:key] ? setup[:key] : setup[:name])
          object[key] = attr_serializer(setup)
        end
      end
    end

    def serialized_from_cache
      return false unless EasySerializer.perform_caching
      cache = __cache
      return false unless cache
      if cache[:block]
        cache[:block].call(klass_ins, self)
      else
        key = if cache[:key]
          cache[:key].call(klass_ins)
        else
          [klass_ins, 'EasySerialized']
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
      content = cache_or_attribute(klass_ins, setup)
      return content unless serializer = setup[:serializer]
      if setup[:collection]
        Array.wrap(content).map { |o|  cache_or_serialize(serializer, o, setup) }
      else
        cache_or_serialize(serializer, content, setup)
      end
    end

    def cache_or_attribute(obj, setup)
      execute = setup[:block] || proc { |o| o.send(setup[:name]) }
      if EasySerializer.perform_caching && setup[:cache] && !setup[:serializer]
        EasySerializer.cache.fetch(obj, setup[:name]) { execute.call(obj) }
      else
        execute.call(obj)
      end
    end

    def cache_or_serialize(serializer, content, opts)
      return unless content
      if EasySerializer.perform_caching && opts[:cache]
        key = if opts[:cache_key]
          opts[:cache_key].call(content)
        else
          [content, 'EasySerialized']
        end
        # Be Aware
        # We are caching the serialized object
        EasySerializer.cache.fetch(key) { send_to_serializer(serializer, content) }
      else
        send_to_serializer(serializer, content)
      end
    end

    def from_setup_serializer(serializer, content)
      case serializer
      when Proc
        serializer.call(self, klass_ins, content)
      else
        serializer
      end
    end

    def send_to_serializer(serializer, content)
      return unless content
      from_setup_serializer(serializer, content).new(content).serialize
    end
  end
end
