#!/usr/bin/env ruby
require 'minitest/autorun'
require 'natour'

class TestGPSTrack < Minitest::Test
  include Minitest
  include Natour

  def test_load_gpx_file
    filename = "#{__dir__}/data/2020-06-01 171703.gpx"
    gps_track = GPSTrack.load_file(filename)
    assert_instance_of(GPXFile, gps_track)
    assert_equal(filename, gps_track.path)
    assert_equal(Date.new(2020, 6, 1), gps_track.date)
    assert_equal(1323, gps_track.ascent)
    assert_equal(1327, gps_track.descent)
    assert_equal(17723, gps_track.distance)
    assert_equal(Duration.new(33522), gps_track.duration)
    assert_equal(
      GPSTrackPoint.new(47.1054272074, 8.9202940185, 917.25, Time.utc(2020, 6, 1, 5, 58, 23)),
      gps_track.start_point
    )
    assert_equal(
      GPSTrackPoint.new(47.1055198275, 8.9199902583, 919.33, Time.utc(2020, 6, 1, 15, 17, 2)),
      gps_track.end_point
    )
  end

  def test_load_fit_file
    filename = "#{__dir__}/data/2020-06-01 17-17-03.fit"
    gps_track = GPSTrack.load_file(filename)
    assert_instance_of(FITFile, gps_track)
    assert_equal(Date.new(2020, 6, 1), gps_track.date)
    assert_equal(1323, gps_track.ascent)
    assert_equal(1327, gps_track.descent)
    assert_equal(17723, gps_track.distance)
    assert_equal(Duration.new(33523), gps_track.duration)
    assert_equal(
      GPSTrackPoint.new(47.10542720742524, 8.9202940184623, 917.2, Time.utc(2020, 6, 1, 5, 58, 23)),
      gps_track.start_point
    )
    assert_equal(
      GPSTrackPoint.new(47.10551982745528, 8.919990258291364, 919.2, Time.utc(2020, 6, 1, 15, 17, 2)),
      gps_track.end_point
    )
  end

  def test_load_gpx_file_without_extensions
    filename = "#{__dir__}/data/2020-11-21 12.22.02.gpx"
    gps_track = GPSTrack.load_file(filename)
    assert_instance_of(GPXFile, gps_track)
    assert_equal(filename, gps_track.path)
    assert_equal(Date.new(2020, 11, 21), gps_track.date)
    assert_nil(gps_track.ascent)
    assert_nil(gps_track.descent)
    assert_nil(gps_track.distance)
    assert_nil(gps_track.duration)
    assert_equal(
      GPSTrackPoint.new(47.4210189376, 8.5090345982, 457.29, Time.utc(2020, 11, 21, 7, 51, 14)),
      gps_track.start_point
    )
    assert_equal(
      GPSTrackPoint.new(47.4210324325, 8.5088066105, 459.34, Time.utc(2020, 11, 21, 11, 22, 1)),
      gps_track.end_point
    )
  end

  def test_round_down
    gps_track = GPSTrack.new(
      'path/to/gps_track',
      Date.new(2020, 12, 21),
      149,
      249,
      3499,
      Duration.new(hours: 4, minutes: 7, seconds: 29),
      GPSTrackPoint.new(0.0, 0.0, 0.0, Time.new(2020, 12, 21, 8, 32, 29)),
      GPSTrackPoint.new(0.0, 0.0, 0.0, Time.new(2020, 12, 21, 8, 37, 29))
    )
    assert_instance_of(GPSTrack, gps_track.round_effective_km!)
    assert_equal('path/to/gps_track', gps_track.path)
    assert_equal(Date.new(2020, 12, 21), gps_track.date)
    assert_equal(100, gps_track.ascent)
    assert_equal(200, gps_track.descent)
    assert_equal(3000, gps_track.distance)
    assert_equal(Duration.new(hours: 4), gps_track.duration)
    assert_equal(
      GPSTrackPoint.new(0.0, 0.0, 0.0, Time.new(2020, 12, 21, 8, 30, 0)),
      gps_track.start_point
    )
    assert_equal(
      GPSTrackPoint.new(0.0, 0.0, 0.0, Time.new(2020, 12, 21, 8, 35, 0)),
      gps_track.end_point
    )
  end

  def test_round_up
    gps_track = GPSTrack.new(
      'path/to/gps_track',
      Date.new(2020, 12, 21),
      150,
      250,
      3500,
      Duration.new(hours: 4, minutes: 7, seconds: 30),
      GPSTrackPoint.new(0.0, 0.0, 0.0, Time.new(2020, 12, 21, 8, 32, 30)),
      GPSTrackPoint.new(0.0, 0.0, 0.0, Time.new(2020, 12, 21, 8, 37, 30))
    )
    assert_instance_of(GPSTrack, gps_track.round_effective_km!)
    assert_equal('path/to/gps_track', gps_track.path)
    assert_equal(Date.new(2020, 12, 21), gps_track.date)
    assert_equal(200, gps_track.ascent)
    assert_equal(300, gps_track.descent)
    assert_equal(4000, gps_track.distance)
    assert_equal(Duration.new(hours: 4, minutes: 15), gps_track.duration)
    assert_equal(
      GPSTrackPoint.new(0.0, 0.0, 0.0, Time.new(2020, 12, 21, 8, 35, 0)),
      gps_track.start_point
    )
    assert_equal(
      GPSTrackPoint.new(0.0, 0.0, 0.0, Time.new(2020, 12, 21, 8, 40, 0)),
      gps_track.end_point
    )
  end
end
