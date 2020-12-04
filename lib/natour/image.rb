require 'vips'
require 'timeliness'

module Natour
  class Image
    attr_reader :path
    attr_reader :date_time

    def initialize(path)
      @path = path
      image = Vips::Image.new_from_file(path)
      width, height = image.size
      @portrait = width < height
      orientation = image.get('exif-ifd0-Orientation')
      @portrait = orientation[/^(\d) \(/, 1].to_i.between?(5, 8)
      date_time = image.get('exif-ifd0-DateTime')
      @date_time = Timeliness.parse(
        date_time[/^(.*?) \(/, 1],
        format: 'yyyy:mm:dd hh:nn:ss'
      )
    rescue Vips::Error => e
      raise unless e.to_s =~ /exif-ifd0-(Orientation|DateTime)/
    end

    def portrait?
      @portrait
    end

    def landscape?
      !portrait?
    end
  end
end
