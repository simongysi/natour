#!/usr/bin/env ruby

require 'minitest/autorun'
require 'natour'

class TestPublicTransport < Minitest::Test
  include Minitest
  include Natour

  def test_search_bus
    position = [47.25626, 9.31856]
    station = PublicTransport.search_station(position)
    assert_equal(
      Station.new('Schwägalp, Säntis-Schwebebahn', :bus, 0),
      station
    )
  end

  def test_search_cablecar
    position = [47.24939, 9.343454]
    station = PublicTransport.search_station(position)
    assert_equal(
      Station.new('Säntis', :cablecar, 103),
      station
    )
  end

  def test_search_no_station
    position = [46.81122, 8.91464]
    station = PublicTransport.search_station(position)
    assert_nil(station)
  end

  def test_search_limted_by_radius
    position = [47.24623, 9.34674]
    station = PublicTransport.search_station(position, radius: 1000)
    assert_equal(
      Station.new('Säntis', :cablecar, 488),
      station
    )
    station = PublicTransport.search_station(position, radius: 200)
    assert_nil(station)
  end

  def test_search_with_position_as_string
    position = '47.24939,9.343454'
    station = PublicTransport.search_station(position)
    assert_equal(
      Station.new('Säntis', :cablecar, 103),
      station
    )
  end

  def test_search_with_position_as_string_with_spaces
    position = ' 47.24939 , 9.343454 '
    station = PublicTransport.search_station(position)
    assert_equal(
      Station.new('Säntis', :cablecar, 103),
      station
    )
  end
end
