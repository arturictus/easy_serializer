module EasySerializer
  class Base
    include Helpers

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

    def send_to_serializer(serializer, value)
      return unless value
      option_to_value(serializer, value).call(value)
    end

    private

    def _serialize
      __serializable_attributes.each_with_object({}) do |setup, hash|
        if setup[:key] === false
          hash.merge!(value_or_default(setup))
        else
          key = (setup[:key] ? setup[:key] : setup[:name])
          hash[key] = value_or_default(setup)
        end
      end
    end

    def serialized_from_cache
      return false unless EasySerializer.perform_caching
      cache = __cache
      return false unless cache
      Cacher.root_call(self, cache, object) { _serialize }
    end

    def __cache
      self.class.instance_variable_get(:@__cache)
    end

    def __serializable_attributes
      self.class.instance_variable_get(:@__serializable_attributes) || []
    end

    def value_or_default(setup)
      value = attr_serializer(setup)
      if value.nil? && setup[:default]
        return option_to_value(setup[:default], object)
      end
      value
    end

    def attr_serializer(setup)
      value = cache_or_attribute(setup)
      return value if value.respond_to?(:fetch) || value.respond_to?(:each)
      return value unless serializer = setup[:serializer]
      if setup[:collection]
        Array.wrap(value).map { |o| cache_or_serialize(serializer, o, setup) }
      else
        cache_or_serialize(serializer, value, setup)
      end
    end

    def cache_or_attribute(setup)
      execute = setup[:block] || proc { |o| o.send(setup[:name]) }
      if EasySerializer.perform_caching && setup[:cache]
        Cacher.call(self, setup, nil, &execute)
      else
        if object.respond_to?(:each)
          object.map { |o| instance_exec o, &execute }
        else
          instance_exec object, &execute
        end
      end
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
