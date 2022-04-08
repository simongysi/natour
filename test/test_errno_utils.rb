#!/usr/bin/env ruby

require 'minitest/autorun'
require 'natour'

class TestErrnoUtils < Minitest::Test
  include Minitest
  include Natour

  def test_split_message
    error = Errno::EEXIST.new('/path/to/file', 'rb_sysopen')
    message, function, path = ErrnoUtils.split_message(error)
    assert_equal('File exists', message)
    assert_equal('rb_sysopen', function)
    assert_equal('/path/to/file', path)
  end

  def test_split_message_with_hyphen
    error = Errno::EEXIST.new('/path/bla - bla/file', 'rb_sysopen')
    message, function, path = ErrnoUtils.split_message(error)
    assert_equal('File exists', message)
    assert_equal('rb_sysopen', function)
    assert_equal('/path/bla - bla/file', path)
  end
end
