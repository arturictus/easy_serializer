module EasySerializer
  class Base
    include Helpers
    extend Forwardable

    def_delegator :serialize, :to_json, :[]

    attr_reader :object, :options
    def initialize(object, options = {})
      @object = object
      @options = options
    end

    class << self

      def call(*args)
        new(*args).serialize
      end
      alias_method :serialize, :call
      alias_method :to_hash, :call
      alias_method :to_h, :call

      def attribute(name, opts = {}, &block)
        @__serializable_attributes ||= []
        @__serializable_attributes << Attribute.new(name, opts, block)
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
        @__serializable_attributes ||= []
        @__serializable_attributes << Collection.new(name, opts, block)
      end
    end

    def serialize
      @serialize ||= serialized_from_cache || _serialize
    end
    alias_method :to_h, :serialize
    alias_method :to_hash, :serialize

    def to_s; serialize.to_json end

    def send_to_serializer(serializer, value)
      return unless value
      option_to_value(serializer, value).call(value)
    end

    def __cache
      self.class.instance_variable_get(:@__cache)
    end

    private

    def _serialize
      __serializable_attributes.each_with_object({}) do |metadata, hash|
        if metadata.options[:key] === false
          hash.merge!(value_or_default(metadata))
        else
          key = (metadata.options[:key] ? metadata.options[:key] : metadata.name)
          hash[key] = value_or_default(metadata)
        end
      end
    end

    def serialized_from_cache
      return false unless EasySerializer.perform_caching
      cache = __cache
      return false unless cache
      RootCacher.call(self){ _serialize }
    end

    def __serializable_attributes
      self.class.instance_variable_get(:@__serializable_attributes) || []
    end

    def value_or_default(metadata)
      AttributeSerializer.call(self, metadata)
    end

  end
end
