require 'pathname'
require 'yaml'

module Natour
  class Config
    def self.load_file(filename, default: {}, dirs: [Dir.home, Dir.pwd])
      dirs.map do |dir|
        YAML.safe_load(
          File.read(Pathname(dir).join(filename)),
          [Symbol]
        )
      rescue Errno::ENOENT
        {}
      end.reduce(default, &:merge)
    end
  end
end
