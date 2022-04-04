require 'duration'
require 'fileutils'
require 'pathname'
require 'time'

module Natour
  class GPSTrack
    attr_reader :path
    attr_reader :date
    attr_reader :ascent
    attr_reader :descent
    attr_reader :distance
    attr_reader :duration
    attr_reader :start_point
    attr_reader :end_point

    def initialize(path, date, ascent, descent, distance, duration, start_point, end_point)
      @path = path
      @date = date
      @ascent = ascent
      @descent = descent
      @distance = distance
      @duration = duration
      @start_point = start_point
      @end_point = end_point
    end

    def self.load_file(filename, format: :auto)
      format = Pathname(filename).extname.to_s.delete_prefix('.').to_sym if format == :auto
      case format
      when :gpx
        GPXFile.new(filename)
      when :fit
        FITFile.new(filename)
      end
    end

    def round_effective_km!
      @ascent = @ascent&.round(-2)
      @descent = @descent&.round(-2)
      @distance = @distance&.round(-3)
      @duration = Duration.new(round_duration(@duration, minutes: 15)) if @duration
      @start_point = GPSTrackPoint.new(
        @start_point.latitude,
        @start_point.longitude,
        @start_point.elevation,
        round_time(@start_point.time, minutes: 5)
      )
      @end_point = GPSTrackPoint.new(
        @end_point.latitude,
        @end_point.longitude,
        @end_point.elevation,
        round_time(@end_point.time, minutes: 5)
      )
      self
    end

    def save_gpx(filename, overwrite: false)
      FileUtils.mkdir_p(Pathname(filename).dirname)
      mode = File::WRONLY | File::CREAT | File::TRUNC
      mode |= File::EXCL unless overwrite
      File.open(filename, mode) do |file|
        file.write(to_gpx)
      end
    end

    private

    def round_multiple_of(number, multiple)
      (number / multiple.to_f).round * multiple
    end

    def round_duration(duration, hours: 0, minutes: 0, seconds: 0)
      return unless duration

      Duration.new(round_multiple_of(duration.to_i, (hours * 60 + minutes) * 60 + seconds))
    end

    def round_time(time, hours: 0, minutes: 0, seconds: 0)
      return unless time

      Time.at(round_multiple_of(time.to_i, (hours * 60 + minutes) * 60 + seconds))
    end
  end
end
