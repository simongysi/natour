#!/usr/bin/env ruby

require 'minitest/autorun'
require 'natour'

class TestConfig < Minitest::Test
  include Minitest
  include Natour

  def test_load_files
    config = Config.load_files([
      "#{__dir__}/data/config/user_config.yml",
      "#{__dir__}/data/config/local_config.yml"
    ])
    assert_equal({
      report: {
        create: {
          out_dir: '~/natour',
          adoc_author: 'John Doe <john.doe@mail.org>',
          track_formats: %i[gpx]
        }
      }
    }, config)
  end

  def test_load_files_with_default
    config = Config.load_files([
      "#{__dir__}/data/config/user_config.yml",
      "#{__dir__}/data/config/local_config.yml"
    ], default: {
      report: {
        create: {
          out_dir: '~/Documents',
          out_file: 'report.adoc',
          track_formats: %i[gpx fit]
        }
      }
    })
    assert_equal({
      report: {
        create: {
          out_dir: '~/natour',
          out_file: 'report.adoc',
          adoc_author: 'John Doe <john.doe@mail.org>',
          track_formats: %i[gpx]
        }
      }
    }, config)
  end

  def test_load_files_priorities
    config = Config.load_files([
      "#{__dir__}/data/config/local_config.yml",
      "#{__dir__}/data/config/user_config.yml"
    ])
    assert_equal({
      report: {
        create: {
          out_dir: '~/natour',
          adoc_author: 'Hans Muster <hans.muster@mail.org>',
          track_formats: %i[fit]
        }
      }
    }, config)
  end

  def test_file_not_existing
    config = Config.load_files([
      "#{__dir__}/data/config/user_config_not_existing.yml"
    ])
    assert_equal({}, config)
  end

  def test_empty_file
    config = Config.load_files([
      "#{__dir__}/data/config/empty_config.yml"
    ])
    assert_equal({}, config)
  end
end
