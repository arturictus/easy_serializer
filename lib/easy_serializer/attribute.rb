module EasySerializer
  class Attribute < Field
    include Helpers

    def default?
      options[:default]
    end

    def get_default(object, serializer)
      return unless default?
      option_to_value(options[:default], object, serializer)
    end

  end
end
