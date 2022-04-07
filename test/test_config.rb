#!/usr/bin/env ruby

require 'minitest/autorun'
require 'natour'

class TestConfig < Minitest::Test
  include Minitest
  include Natour

  def test_load_file
    config = Config.load_file(
      'config.yml',
      dirs: [
        "#{__dir__}/data/config/user",
        "#{__dir__}/data/config/local"
      ]
    )
    assert_equal({
      'out-dir' => '~/natour',
      'adoc-author' => 'John Doe <john.doe@mail.org>'
    }, config)
  end

  def test_load_file_with_default
    config = Config.load_file(
      'config.yml',
      default: {
        'out-dir' => '~/Documents',
        'out-file' => 'report.adoc'
      },
      dirs: [
        "#{__dir__}/data/config/user",
        "#{__dir__}/data/config/local"
      ]
    )
    assert_equal({
      'out-dir' => '~/natour',
      'out-file' => 'report.adoc',
      'adoc-author' => 'John Doe <john.doe@mail.org>'
    }, config)
  end

  def test_load_file_reverse_dirs
    config = Config.load_file(
      'config.yml',
      dirs: [
        "#{__dir__}/data/config/local",
        "#{__dir__}/data/config/user"
      ]
    )
    assert_equal({
      'out-dir' => '~/natour',
      'adoc-author' => 'Hans Muster <hans.muster@mail.org>'
    }, config)
  end

  def test_file_not_existing
    config = Config.load_file(
      'config-not-existing.yml',
      dirs: [
        "#{__dir__}/data/config/user"
      ]
    )
    assert_equal({}, config)
  end

  def test_dir_not_existing
    config = Config.load_file(
      'config.yml',
      dirs: [
        "#{__dir__}/data/config/not-existing"
      ]
    )
    assert_equal({}, config)
  end
end
