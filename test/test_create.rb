#!/usr/bin/env ruby
require 'minitest/autorun'
require 'natour'

class TestCreate < Minitest::Test
  include Minitest
  include Natour

  def test_create
    Dir.mktmpdir do |tmp_dir|
      filenames = create(
        "#{__dir__}/data/2020-02-15 Flachsee",
        out_dir: tmp_dir,
        create_map: false
      )
      assert_equal(2, filenames.count)
      assert_equal(Pathname(tmp_dir).join('2020-02-15 Flachsee.adoc').to_s, filenames[0])
      assert_equal(Pathname(tmp_dir).join('2020-02-15 Flachsee (2).adoc').to_s, filenames[1])
    end
  end
end
