# frozen_string_literal: true

require 'test_helper'
require 'stringio'

class StowManCLITest < Minitest::Test
  def test_version_flag_prints_version
    out = StringIO.new
    err = StringIO.new

    code = StowMan::CLI.start(['--version'], out: out, err: err)

    assert_equal 0, code
    assert_equal "stow-man #{StowMan::VERSION}\n", out.string
    assert_equal '', err.string
  end

  def test_help_flag_prints_help
    out = StringIO.new
    err = StringIO.new

    code = StowMan::CLI.start(['--help'], out: out, err: err)

    assert_equal 0, code
    assert_includes out.string, 'Usage: stow-man'
    assert_equal '', err.string
  end

  def test_no_command_prints_help
    out = StringIO.new
    err = StringIO.new

    code = StowMan::CLI.start([], out: out, err: err)

    assert_equal 0, code
    assert_includes out.string, 'Commands:'
    assert_equal '', err.string
  end

  def test_unknown_command_returns_usage_error
    out = StringIO.new
    err = StringIO.new

    code = StowMan::CLI.start(['wat'], out: out, err: err)

    assert_equal 2, code
    assert_equal '', out.string
    assert_includes err.string, 'Unknown command: wat'
  end

end
