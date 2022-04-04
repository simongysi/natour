require 'fileutils'
require 'pathname'
require 'timeliness'
require 'vips'

module Natour
  class Image
    attr_reader :path
    attr_reader :date_time

    def initialize(path, image)
      @path = path
      @image = image
      @landscape = image.width >= image.height
      orientation = get_field('exif-ifd0-Orientation')
      @landscape = !@landscape if orientation && orientation[/^(\d) \(/, 1].to_i.between?(5, 8)
      date_time = get_field('exif-ifd0-DateTime')
      @date_time = Timeliness.parse(date_time[/^(.*?) \(/, 1], format: 'yyyy:mm:dd hh:nn:ss') if date_time
    end

    def self.load_file(filename)
      Image.new(filename, Vips::Image.new_from_file(filename))
    end

    def landscape?
      @landscape
    end

    def autorotate
      Image.new(@path, @image.autorot)
    end

    def shrink_to(maxdim)
      scale = maxdim / @image.size.max.to_f
      image = if scale < 1.0
                @image.resize(scale)
              else
                @image.copy
              end
      Image.new(@path, image)
    end

    def save_as(filename)
      FileUtils.mkdir_p(Pathname(filename).dirname)
      StdoutUtils.suppress_output { @image.write_to_file(filename) }
    end

    private

    def get_field(name)
      @image.get(name) if @image.get_fields.include?(name)
    end
  end
end
