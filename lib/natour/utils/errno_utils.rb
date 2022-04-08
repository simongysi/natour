module Natour
  module ErrnoUtils
    module_function

    def split_message(error)
      error.message.split(/ @ | - /, 3)
    end
  end
end
