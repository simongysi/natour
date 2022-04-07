#!/usr/bin/env ruby

require 'minitest/autorun'
require 'natour'
require 'pathname'

class TestConvert < Minitest::Test
  include Minitest
  include Natour

  def test_convert
    Dir.mktmpdir do |tmp_dir|
      filenames = create(
        "#{__dir__}/data/2020-02-15 Flachsee",
        out_dir: tmp_dir,
        create_map: false
      ).map { |filename| convert(filename) }
      assert_equal(2, filenames.count)
      assert_equal(Pathname(tmp_dir).join('2020-02-15 Flachsee.pdf').to_s, filenames[0])
      assert_equal(Pathname(tmp_dir).join('2020-02-15 Flachsee (2).pdf').to_s, filenames[1])
    end
  end
end
