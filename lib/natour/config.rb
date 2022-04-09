require 'deep_merge/rails_compat'
require 'pathname'
require 'yaml'

module Natour
  class Config
    def self.load_file(filename, default: {}, dirs: [Dir.home, Dir.pwd])
      configs = dirs.map do |dir|
        config = YAML.safe_load(
          File.read(Pathname(dir).join(filename)),
          permitted_classes: [Symbol]
        )
        config || {}
      rescue Errno::ENOENT
        {}
      end
      configs.reduce(default) { |dst, src| dst.deeper_merge!(src, overwrite_arrays: true) }
    end
  end
end
