#!/usr/bin/env ruby

require 'minitest/autorun'
require 'natour'

class TestErrnoUtils < Minitest::Test
  include Minitest
  include Natour

  def test_split_message_without_path_and_function
    error = Errno::EEXIST.new
    message, function, path = ErrnoUtils.split_message(error)
    assert_equal('File exists', message)
    assert_nil(function)
    assert_nil(path)
  end

  def test_split_message_with_empty_path_only
    error = Errno::EEXIST.new('')
    message, function, path = ErrnoUtils.split_message(error)
    assert_equal('File exists', message)
    assert_nil(function)
    assert_equal('', path)
  end

  def test_split_message_with_empty_path_and_function
    error = Errno::EEXIST.new('', 'rb_sysopen')
    message, function, path = ErrnoUtils.split_message(error)
    assert_equal('File exists', message)
    assert_equal('rb_sysopen', function)
    assert_equal('', path)
  end

  def test_split_message_with_path_only
    error = Errno::EEXIST.new('/path/to/file')
    message, function, path = ErrnoUtils.split_message(error)
    assert_equal('File exists', message)
    assert_nil(function)
    assert_equal('/path/to/file', path)
  end

  def test_split_message_with_path_and_function
    error = Errno::EEXIST.new('/path/to/file', 'rb_sysopen')
    message, function, path = ErrnoUtils.split_message(error)
    assert_equal('File exists', message)
    assert_equal('rb_sysopen', function)
    assert_equal('/path/to/file', path)
  end

  def test_split_message_with_path_containing_hypen_and_function
    error = Errno::EEXIST.new('/path/bla - bla/file', 'rb_sysopen')
    message, function, path = ErrnoUtils.split_message(error)
    assert_equal('File exists', message)
    assert_equal('rb_sysopen', function)
    assert_equal('/path/bla - bla/file', path)
  end
end
