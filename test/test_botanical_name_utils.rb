#!/usr/bin/env ruby
require 'minitest/autorun'
require 'natour'

class TestBotanicalNameUtils < Minitest::Test
  include Minitest
  include Natour

  def test_parse
    assert_nil(BotanicalNameUtils.parse(''))
    assert_nil(BotanicalNameUtils.parse('Veronica'))
    assert_equal('Veronica fruticans', BotanicalNameUtils.parse('Veronica fruticans Jacq.'))
    assert_equal('Silene vulgaris', BotanicalNameUtils.parse('Silene vulgaris (Moench) Garcke'))
    assert_equal('Alchemilla conjuncta aggr.', BotanicalNameUtils.parse('Alchemilla conjuncta aggr.'))
    assert_equal('Carduus defloratus', BotanicalNameUtils.parse('Carduus defloratus L.'))
    assert_equal(
      'Carduus defloratus subsp. defloratus', BotanicalNameUtils.parse('Carduus defloratus L. subsp. defloratus')
    )
    assert_equal('Pulsatilla alpina', BotanicalNameUtils.parse('Pulsatilla alpina (L.) Delarbre'))
    assert_equal(
      'Pulsatilla alpina subsp. alpina', BotanicalNameUtils.parse('Pulsatilla alpina (L.) Delarbre subsp. alpina')
    )
    assert_equal(
      'Juniperus communis subsp. alpina', BotanicalNameUtils.parse('Juniperus communis subsp. alpina Čelak.')
    )
  end
end
