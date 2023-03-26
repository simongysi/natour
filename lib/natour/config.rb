require 'deep_merge/rails_compat'
require 'pathname'
require 'yaml'

module Natour
  class Config
    def self.load_files(filenames, default: {})
      configs = filenames.map do |filename|
        config = YAML.safe_load(File.read(filename), permitted_classes: [Symbol])
        config || {}
      rescue Errno::ENOENT
        {}
      end
      configs.reduce(default) { |dst, src| dst.deeper_merge!(src, overwrite_arrays: true) }
    end
  end
end
