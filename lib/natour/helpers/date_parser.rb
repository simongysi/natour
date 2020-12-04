require 'timeliness'

module Natour
  module DateParser
    module_function

    def parse(*args)
      args.map { |arg| Timeliness.parse(arg.to_s[/^(\d{4}-\d{2}-\d{2})/])&.to_date }
    end
  end
end
