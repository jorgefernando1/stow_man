require 'test_helper'

class StowManTest < Minitest::Test
  def test_has_a_version_number
    refute_nil ::StowMan::VERSION
  end
end
