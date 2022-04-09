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
      report: {
        create: {
          out_dir: '~/natour',
          adoc_author: 'John Doe <john.doe@mail.org>',
          track_formats: %i[gpx]
        }
      }
    }, config)
  end

  def test_load_file_with_default
    config = Config.load_file(
      'config.yml',
      default: {
        report: {
          create: {
            out_dir: '~/Documents',
            out_file: 'report.adoc',
            track_formats: %i[gpx fit]
          }
        }
      },
      dirs: [
        "#{__dir__}/data/config/user",
        "#{__dir__}/data/config/local"
      ]
    )
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

  def test_load_file_priorities
    config = Config.load_file(
      'config.yml',
      dirs: [
        "#{__dir__}/data/config/local",
        "#{__dir__}/data/config/user"
      ]
    )
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

  def test_empty_file
    config = Config.load_file(
      'empty_config.yml',
      dirs: [
        "#{__dir__}/data/config"
      ]
    )
    assert_equal({}, config)
  end
end
