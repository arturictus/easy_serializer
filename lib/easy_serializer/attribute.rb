module EasySerializer
  class Attribute < Field
    def get_value
      block || method(:send_name)
    end
  end
end
