#!/usr/bin/env ruby
require 'minitest/autorun'
require 'natour'

class TestDateParser < Minitest::Test
  include Minitest
  include Natour

  def test_parse
    assert_equal([], DateParser.parse)
    assert_equal([nil], DateParser.parse(nil))
    assert_equal([nil, Date.new(2020, 12, 21)], DateParser.parse(nil, Date.new(2020, 12, 21)))
    assert_equal([nil, Date.new(2020, 12, 21)], DateParser.parse(nil, '2020-12-21'))
    assert_equal(
      [nil, Date.new(2020, 12, 21), Date.new(2020, 6, 7)], DateParser.parse(nil, Date.new(2020, 12, 21), '2020-06-07')
    )
    assert_equal([Date.new(2020, 12, 21)], DateParser.parse('2020-12-21'))
    assert_equal([Date.new(2020, 12, 21)], DateParser.parse('2020-12-21 Der Jura'))
    assert_equal([nil], DateParser.parse('Der Jura'))
    assert_equal([nil], DateParser.parse('20-12-21'))
    assert_equal([nil], DateParser.parse('12-21'))
    assert_equal([nil], DateParser.parse('20.12.21'))
    assert_equal([nil], DateParser.parse('12.21'))
    assert_equal([nil], DateParser.parse('201221'))
    assert_equal([nil], DateParser.parse('1221'))
    assert_equal([nil], DateParser.parse('21'))
  end
end
