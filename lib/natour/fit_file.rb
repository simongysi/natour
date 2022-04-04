require 'date'
require 'duration'
require 'fit4ruby'
require 'nokogiri'
require 'time'

module Natour
  class FITFile < GPSTrack
    def initialize(filename)
      Fit4Ruby::Log.level = Logger::ERROR
      @activity = Fit4Ruby.read(filename)

      date = Date.parse(@activity.local_timestamp.to_s)
      session = @activity.sessions.first
      ascent = session.total_ascent
      descent = session.total_descent
      distance = session.total_distance.to_i
      duration = Duration.new(session.total_elapsed_time)

      records = @activity.records.reject { |record| [record.position_lat, record.position_lat].any?(&:nil?) }
      start_point = to_track_point(records[0])
      end_point = to_track_point(records[-1])

      super(filename, date, ascent, descent, distance, duration, start_point, end_point)
    end

    def to_gpx
      decl = Nokogiri.XML('<?xml version="1.0" encoding="UTF-8" standalone="no"?>')
      builder = Nokogiri::XML::Builder.with(decl) do |doc|
        doc.gpx(
          'creator' => 'natour',
          'version' => '1.1',
          'xmlns' => 'http://www.topografix.com/GPX/1/1',
          'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
          'xsi:schemaLocation' => 'http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd'
        ) do
          doc.trk do
            doc.trkseg do
              records = @activity.records.reject { |record| [record.position_lat, record.position_lat].any?(&:nil?) }
              records.each do |record|
                doc.trkpt('lat' => record.position_lat, 'lon' => record.position_long) do
                  doc.ele record.enhanced_elevation
                  doc.time record.timestamp.utc.xmlschema
                end
              end
            end
          end
        end
      end

      builder.to_xml
    end

    private

    def to_track_point(record)
      GPSTrackPoint.new(
        record.position_lat,
        record.position_long,
        record.enhanced_elevation,
        Time.parse(record.timestamp.to_s).utc
      )
    end
  end
end
