#!/usr/bin/env ruby

require 'minitest/autorun'
require 'natour'
require 'pathname'

class TestMapGeoAdmin < Minitest::Test
  include Minitest
  include Natour

  def test_save_image
    MapGeoAdmin.open do |map|
      Dir.mktmpdir do |tmp_dir|
        filename = Pathname(tmp_dir).join('2020-06-01 171703.jpg')
        map.save_image(
          filename,
          gps_files: [
            "#{__dir__}/data/2020-06-01 171703.gpx"
          ]
        )
        assert(filename.file?)
        assert_operator filename.size, :>, 1260000
      end
    end
  end

  def test_save_image_multiple_tracks
    MapGeoAdmin.open do |map|
      Dir.mktmpdir do |tmp_dir|
        filename = Pathname(tmp_dir).join('2020-06-26 161735_2020-06-27 153130.jpg')
        map.save_image(
          filename,
          gps_files: [
            "#{__dir__}/data/2020-06-26 Gräserkurs in Amden/2020-06-26 161735.gpx",
            "#{__dir__}/data/2020-06-26 Gräserkurs in Amden/2020-06-27 153130.gpx"
          ]
        )
        assert(filename.file?)
        assert_operator filename.size, :>, 1167000
      end
    end
  end

  def test_save_image_additional_layers
    MapGeoAdmin.open do |map|
      Dir.mktmpdir do |tmp_dir|
        filename = Pathname(tmp_dir).join('2020-06-01 171703.jpg')
        map.save_image(
          filename,
          gps_files: [
            "#{__dir__}/data/2020-06-01 171703.gpx"
          ],
          map_layers: [
            'ch.swisstopo.swisstlm3d-wanderwege',
            'ch.bav.haltestellen-oev'
          ]
        )
        assert(filename.file?)
        assert_operator filename.size, :>, 1275000
      end
    end
  end

  def test_save_image_dont_overwrite
    MapGeoAdmin.open do |map|
      Dir.mktmpdir do |tmp_dir|
        filename = Pathname(tmp_dir).join('2020-06-01 171703.jpg')
        File.write(filename, 'Hello World')
        assert_raises(Errno::EEXIST) do
          map.save_image(
            filename,
            gps_files: [
              "#{__dir__}/data/2020-06-01 171703.gpx"
            ]
          )
        end
        assert_equal('Hello World', File.read(filename))
      end
    end
  end
end
