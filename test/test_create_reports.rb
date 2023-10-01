#!/usr/bin/env ruby

require 'minitest/autorun'
require 'natour'
require 'pathname'

class TestCreate < Minitest::Test
  include Minitest
  include Natour

  def test_create_reports
    Dir.mktmpdir do |tmp_dir|
      filenames = create_reports(
        "#{__dir__}/data/2020-02-15 Flachsee",
        out_dir: tmp_dir,
        create_map: false
      )
      assert_equal(2, filenames.count)
      assert_equal(Pathname(tmp_dir).join('2020-02-15 Flachsee.adoc').to_s, filenames[0])
      assert_equal(Pathname(tmp_dir).join('2020-02-15 Flachsee (2).adoc').to_s, filenames[1])
    end
  end

  def test_create_reports_empty_species_list
    Dir.mktmpdir do |tmp_dir|
      filenames = create_reports(
        "#{__dir__}/data/2023-09-23 Vogelzug",
        out_dir: tmp_dir,
        create_map: false
      )
      assert_equal(1, filenames.count)
      assert_equal(Pathname(tmp_dir).join('2023-09-23 Vogelzug.adoc').to_s, filenames[0])
    end
  end
end
