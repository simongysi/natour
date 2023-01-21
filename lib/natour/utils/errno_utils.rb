module Natour
  module ErrnoUtils
    module_function

    def split_message(error)
      tokens = error.message.split(/ @ | - /, 3)
      tokens.insert(1, *[nil] * (3 - tokens.size))
      tokens
    end
  end
end
