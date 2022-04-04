#!/usr/bin/env ruby
require 'date'
require 'minitest/autorun'
require 'natour'

class TestReport < Minitest::Test
  include Minitest
  include Natour

  def test_load_directory
    dir = "#{__dir__}/data/2020-02-15 Flachsee"
    reports = Report.load_directory(dir, create_map: false)
    assert_equal(2, reports.count)
    reports.each do |report|
      assert_equal(dir, report.path)
      assert_equal('Flachsee', report.title)
      assert_equal([
        'Bilder/IMG_5999.JPG',
        'Bilder/IMG_6056.JPG'
      ], report.images.map(&:path))
      assert_equal([
        '2020-02-15Flachsee.csv'
      ], report.species_lists.map(&:path))
      assert_nil(report.map_image)
      assert_equal('Unterlunkhofen, Gemeindehaus', report.starting_point)
      assert_equal('Rottenschwil, Hecht', report.arrival_point)
    end
    assert_equal([
      '2020-02-15 11-27-45.fit',
      '2020-02-15 112745.gpx'
    ], reports.map(&:gps_track).map(&:path).sort)
  end

  def test_load_directory_dot
    Dir.chdir("#{__dir__}/data/2020-02-15 Flachsee") do
      dir = '.'
      reports = Report.load_directory(dir, create_map: false)
      assert_equal(2, reports.count)
      reports.each do |report|
        assert_equal(dir, report.path)
        assert_equal('Flachsee', report.title)
        assert_equal([
          'Bilder/IMG_5999.JPG',
          'Bilder/IMG_6056.JPG'
        ], report.images.map(&:path))
        assert_equal([
          '2020-02-15Flachsee.csv'
        ], report.species_lists.map(&:path))
        assert_nil(report.map_image)
        assert_equal('Unterlunkhofen, Gemeindehaus', report.starting_point)
        assert_equal('Rottenschwil, Hecht', report.arrival_point)
      end
      assert_equal([
        '2020-02-15 11-27-45.fit',
        '2020-02-15 112745.gpx'
      ], reports.map(&:gps_track).map(&:path).sort)
    end
  end

  def test_load_directory_no_gps_track_and_multiple_species_lists
    dir = "#{__dir__}/data/2020-03-08 Neeracherried"
    reports = Report.load_directory(dir, create_map: false)
    assert_equal(1, reports.count)
    report = reports.first
    assert_equal(dir, report.path)
    assert_equal('Neeracherried', report.title)
    assert_equal([
      'Bilder/IMG_6079.JPG',
      'Bilder/IMG_6163.JPG'
    ], report.images.map(&:path))
    assert_equal([
      'flora_helvetica_sammlungen3.csv',  # 2020-04-23
      'flora_helvetica_sammlungen2.csv',  # 2020-05-03
      'flora_helvetica_sammlungen.csv',   # -
      '2020-03-08Neeracherried.csv',      # 2020-03-08
      'Schaare.csv'                       # -
    ], report.species_lists.map(&:path))
    assert_nil(report.gps_track)
    assert_nil(report.map_image)
    assert_nil(report.starting_point)
    assert_nil(report.arrival_point)
  end

  def test_load_directory_multi_day
    dir = "#{__dir__}/data/2020-06-26 Gräserkurs in Amden"
    reports = Report.load_directory(dir, create_map: false)
    assert_equal(2, reports.count)

    report = reports[0]
    assert_equal(dir, report.path)
    assert_equal('Gräserkurs in Amden', report.title)
    assert_equal([
      'Bilder/IMG_9999.JPG',  # 12:23:51
      'Bilder/IMG_0001.JPG',  # 15:35:13
      'Bilder/IMG_0000.JPG'   # -
    ], report.images.map(&:path))
    assert_equal([
      'flora_helvetica_sammlungen.csv'
    ], report.species_lists.map(&:path))
    assert_equal([
      Date.new(2020, 6, 26)
    ], report.species_lists.map(&:date))
    assert_equal('2020-06-26 161735.gpx', report.gps_track.path)
    assert_equal(Date.new(2020, 6, 26), report.gps_track.date)
    assert_nil(report.map_image)
    assert_equal('Niederschlag', report.starting_point)
    assert_equal('Niederschlag', report.arrival_point)

    report2 = reports[1]
    assert_equal(dir, report2.path)
    assert_equal('Gräserkurs in Amden', report2.title)
    assert_equal([
      'Bilder/IMG_0002.JPG',  # 12:37:26
      'Bilder/IMG_0003.JPG',  # 15:23:02
      'Bilder/IMG_0000.JPG'   # -
    ], report2.images.map(&:path))
    assert_equal([
      'flora_helvetica_sammlungen.csv'
    ], report2.species_lists.map(&:path))
    assert_equal([
      Date.new(2020, 6, 27)
    ], report2.species_lists.map(&:date))
    assert_equal('2020-06-27 153130.gpx', report2.gps_track.path)
    assert_equal(Date.new(2020, 6, 27), report2.gps_track.date)
    assert_nil(report2.map_image)
    assert_equal('Niederschlag', report2.starting_point)
    assert_equal('Niederschlag', report2.arrival_point)
  end

  def test_load_directory_with_gpx_file_with_only_mandatory_elements
    dir = "#{__dir__}/data/2021-10-06 Chatzensee"
    reports = Report.load_directory(dir, create_map: false)
    assert_equal(1, reports.count)
    report = reports.first
    assert_equal(dir, report.path)
    assert_equal('Chatzensee', report.title)
    assert_equal([], report.images.map(&:path))
    assert_equal([], report.species_lists.map(&:path))
    assert_equal('chatzensee.gpx', report.gps_track.path)
    assert_nil(report.gps_track.date)
    assert_nil(report.map_image)
    assert_equal('Zürich Affoltern', report.starting_point)
    assert_equal('Zürich Affoltern', report.arrival_point)
  end
end
