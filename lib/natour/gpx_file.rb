require 'duration'
require 'nokogiri'
require 'timeliness'

module Natour
  class GPXFile < GPSTrack
    GPX_XMLNS = {
      'xmlns' => 'http://www.topografix.com/GPX/1/1',
      'xmlns:gpxtrkx' => 'http://www.garmin.com/xmlschemas/TrackStatsExtension/v1'
    }.freeze

    attr_reader :types

    def initialize(filename)
      @doc = Nokogiri.XML(File.read(filename, mode: 'r:utf-8'))

      @types = []
      @types << :waypoint if @doc.at('/xmlns:gpx/xmlns:wpt', GPX_XMLNS)
      @types << :route if @doc.at('/xmlns:gpx/xmlns:rte', GPX_XMLNS)
      @types << :track if @doc.at('/xmlns:gpx/xmlns:trk', GPX_XMLNS)

      stats = @doc.at('/xmlns:gpx/xmlns:trk/xmlns:extensions/gpxtrkx:TrackStatsExtension', GPX_XMLNS)
      if stats
        ascent = stats.at('./gpxtrkx:Ascent', GPX_XMLNS).text.to_i
        descent = stats.at('./gpxtrkx:Descent', GPX_XMLNS).text.to_i
        distance = stats.at('./gpxtrkx:Distance', GPX_XMLNS).text.to_i
        duration = Duration.new(stats.at('./gpxtrkx:TotalElapsedTime', GPX_XMLNS).text.to_i)
      end

      start_point = to_track_point(@doc.at('/xmlns:gpx/xmlns:trk/xmlns:trkseg[1]/xmlns:trkpt[1]', GPX_XMLNS))
      end_point = to_track_point(@doc.at('/xmlns:gpx/xmlns:trk/xmlns:trkseg[last()]/xmlns:trkpt[last()]', GPX_XMLNS))

      super(filename, start_point&.time&.to_date, ascent, descent, distance, duration, start_point, end_point)
    end

    def to_gpx
      @doc.to_xml
    end

    private

    def to_track_point(trkpt)
      return nil unless trkpt

      GPSTrackPoint.new(
        trkpt['lat'].to_f,
        trkpt['lon'].to_f,
        trkpt.at('./xmlns:ele')&.text&.to_f,
        Timeliness.parse(trkpt.at('./xmlns:time')&.text)
      )
    end
  end
end
