#!/usr/bin/env ruby

require 'minitest/autorun'
require 'natour'

class TestBooleanUtils < Minitest::Test
  include Minitest
  include Natour

  def test_to_boolean
    assert_equal(true, BooleanUtils.to_boolean(true))
    assert_equal(false, BooleanUtils.to_boolean(false))
    assert_equal(true, BooleanUtils.to_boolean(true, default_value: false))
    assert_equal(false, BooleanUtils.to_boolean(false, default_value: true))
    assert_equal(false, BooleanUtils.to_boolean(nil))
    assert_equal(true, BooleanUtils.to_boolean(nil, default_value: true))
    assert_equal(false, BooleanUtils.to_boolean(nil, default_value: false))
    assert_equal(false, BooleanUtils.to_boolean(nil, default_value: nil))
    assert_equal(true, BooleanUtils.to_boolean(nil, default_value: 27))
    assert_equal(true, BooleanUtils.to_boolean(nil, default_value: 'Hello'))
  end
end
