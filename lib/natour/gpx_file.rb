require 'nokogiri'
require 'duration'
require 'date'
require 'time'

module Natour
  class GPXFile < GPSTrack
    def initialize(filename)
      @doc = Nokogiri.XML(File.read(filename, mode: 'r:utf-8'))

      date = Date.parse(@doc.at('/xmlns:gpx/xmlns:metadata/xmlns:time').text)
      stats = @doc.at('/xmlns:gpx/xmlns:trk/xmlns:extensions/gpxtrkx:TrackStatsExtension')
      if stats
        ascent = stats.at('./gpxtrkx:Ascent').text.to_i
        descent = stats.at('./gpxtrkx:Descent').text.to_i
        distance = stats.at('./gpxtrkx:Distance').text.to_i
        duration = Duration.new(stats.at('./gpxtrkx:TotalElapsedTime').text.to_i)
      end

      start_point = to_track_point(@doc.at('/xmlns:gpx/xmlns:trk/xmlns:trkseg[1]/xmlns:trkpt[1]'))
      end_point = to_track_point(@doc.at('/xmlns:gpx/xmlns:trk/xmlns:trkseg[last()]/xmlns:trkpt[last()]'))

      super(filename, date, ascent, descent, distance, duration, start_point, end_point)
    end

    def to_gpx
      @doc.to_xml
    end

    private

    def to_track_point(trkpt)
      GPSTrackPoint.new(
        trkpt['lat'].to_f,
        trkpt['lon'].to_f,
        trkpt.at('./xmlns:ele').text.to_f,
        Time.parse(trkpt.at('./xmlns:time').text)
      )
    end
  end
end
