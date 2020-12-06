#!/usr/bin/env ruby
require 'minitest/autorun'
require 'natour'

class TestImage < Minitest::Test
  include Minitest
  include Natour

  def test_image_not_found
    assert_raises(Vips::Error) { Image.new('NOT_EXISTING.JPG') }
  end

  def test_image_no_exif_data
    filename = "#{__dir__}/data/2020-06-26 Gräserkurs in Amden/Bilder/IMG_0000.JPG"
    image = Image.new(filename)
    assert_equal(filename, image.path)
    assert_nil(image.date_time)
    assert(!image.portrait?)
    assert(image.landscape?)
  end

  def test_image_with_date_landscape
    filename = "#{__dir__}/data/2020-06-26 Gräserkurs in Amden/Bilder/IMG_0001.JPG"
    image = Image.new(filename)
    assert_equal(filename, image.path)
    assert_equal(Time.new(2020, 6, 26, 15, 35, 13), image.date_time)
    assert(!image.portrait?)
    assert(image.landscape?)
  end

  def test_image_with_date_portrait
    filename = "#{__dir__}/data/2020-06-26 Gräserkurs in Amden/Bilder/IMG_0002.JPG"
    image = Image.new(filename)
    assert_equal(filename, image.path)
    assert_equal(Time.new(2020, 6, 27, 12, 37, 26), image.date_time)
    assert(image.portrait?)
    assert(!image.landscape?)
  end

  def test_image_with_date_but_no_orientation
    filename = "#{__dir__}/data/IMG_20201009_151300.jpg"
    image = Image.new(filename)
    assert_equal(filename, image.path)
    assert_equal(Time.new(2020, 10, 9, 15, 13, 0), image.date_time)
    assert(image.portrait?)
    assert(!image.landscape?)
  end
end
