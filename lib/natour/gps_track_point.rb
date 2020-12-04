module Natour
  class GPSTrackPoint
    attr_reader :latitude
    attr_reader :longitude
    attr_reader :elevation
    attr_reader :time

    def initialize(latitude, longitude, elevation, time)
      @latitude = latitude
      @longitude = longitude
      @elevation = elevation
      @time = time
    end

    include Comparable

    def <=>(other)
      [@latitude, @longitude, @elevation, @time] <=>
        [other.latitude, other.longitude, other.elevation, other.time]
    end

    def hash
      [@latitude, @longitude, @elevation, @time].hash
    end

    alias eql? ==
  end
end
