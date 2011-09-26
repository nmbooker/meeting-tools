#! /usr/bin/env ruby

require 'test/unit'
require_relative 'numbering'

class NumberingTest < Test::Unit::TestCase
  def test_numbering
    numbering = Numbering.new
    assert_equal("0.1", numbering.h2)
    assert_equal("1", numbering.h1)
    assert_equal("1.1", numbering.h2)
    assert_equal("1.2", numbering.h2)
    assert_equal("1.2.1", numbering.h3)
    assert_equal("1.3", numbering.h2)
    assert_equal("2", numbering.h1)
    assert_equal("2.1", numbering.h2)
    assert_equal("2.1.1", numbering.h3)
    assert_equal("2.1.1.1", numbering.h4)
  end
end
