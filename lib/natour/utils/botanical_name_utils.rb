module Natour
  module BotanicalNameUtils
    module_function

    def parse(name)
      result = name.match(/^([^ ]+ [^ ]+)(( aggr\.)|(.*( subsp\. [^ ]+)))?.*$/)
      return unless result

      "#{result[1]}#{result[3]}#{result[5]}"
    end
  end
end
