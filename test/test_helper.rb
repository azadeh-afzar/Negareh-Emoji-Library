# frozen_string_literal: true

# start code coverage tracker
require "simplecov"
SimpleCov.minimum_coverage 90
SimpleCov.start do
  add_filter "/vendor/"
  add_filter "/db/"
end

require "minitest/autorun"
require "negarmoji"

class TestCase < MiniTest::Test
  def self.test(name, &block)
    define_method(:"test_#{name.inspect}", &block)
  end
end
