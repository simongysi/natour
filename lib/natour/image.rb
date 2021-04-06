require 'vips'
require 'timeliness'

module Natour
  class Image
    attr_reader :path
    attr_reader :date_time

    def initialize(path)
      @path = path
      image = Vips::Image.new_from_file(path)
      get_field = ->(name) { image.get(name) if image.get_fields.include?(name) }
      orientation = get_field.call('exif-ifd0-Orientation')
      @landscape = if orientation
                     orientation[/^(\d) \(/, 1].to_i.between?(1, 4)
                   else
                     image.width >= image.height
                   end
      date_time = get_field.call('exif-ifd0-DateTime')
      @date_time = Timeliness.parse(date_time[/^(.*?) \(/, 1], format: 'yyyy:mm:dd hh:nn:ss') if date_time
    end

    def landscape?
      @landscape
    end
  end
end
