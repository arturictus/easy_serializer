module EasySerializer
  module Helpers
    def option_to_value(option, value, instance = nil)
      inst = instance || self
      case option
      when Proc
        inst.instance_exec value, &option
        # TODO
        # Will be nice to be able to add classes in the options responding to call
        # for complex algorithms.
        # when ->(opt) { opt.respond_to?(:call) }
      else
        option
      end
    end
  end
end
