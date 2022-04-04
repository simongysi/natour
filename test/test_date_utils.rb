#!/usr/bin/env ruby
require 'date'
require 'minitest/autorun'
require 'natour'

class TestDateUtils < Minitest::Test
  include Minitest
  include Natour

  def test_parse
    assert_equal([], DateUtils.parse)
    assert_equal([nil], DateUtils.parse(nil))
    assert_equal([nil, Date.new(2020, 12, 21)], DateUtils.parse(nil, Date.new(2020, 12, 21)))
    assert_equal([nil, Date.new(2020, 12, 21)], DateUtils.parse(nil, '2020-12-21'))
    assert_equal(
      [nil, Date.new(2020, 12, 21), Date.new(2020, 6, 7)], DateUtils.parse(nil, Date.new(2020, 12, 21), '2020-06-07')
    )
    assert_equal([Date.new(2020, 12, 21)], DateUtils.parse('2020-12-21'))
    assert_equal([Date.new(2020, 12, 21)], DateUtils.parse('2020-12-21 Der Jura'))
    assert_equal([nil], DateUtils.parse('Der Jura'))
    assert_equal([nil], DateUtils.parse('20-12-21'))
    assert_equal([nil], DateUtils.parse('12-21'))
    assert_equal([nil], DateUtils.parse('20.12.21'))
    assert_equal([nil], DateUtils.parse('12.21'))
    assert_equal([nil], DateUtils.parse('201221'))
    assert_equal([nil], DateUtils.parse('1221'))
    assert_equal([nil], DateUtils.parse('21'))
  end
end
