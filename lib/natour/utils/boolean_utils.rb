module Natour
  module BooleanUtils
    module_function

    def to_boolean(value, default_value: false)
      return !!value unless value.nil?

      !!default_value
    end
  end
end
