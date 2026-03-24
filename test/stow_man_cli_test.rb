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

  def test_parse_defaults_and_command
    options, = StowMan::CLI.parse(['list'], pwd: '/tmp/dotfiles')

    assert_equal '/tmp/dotfiles/.stow-man.yml', options.config_path
    assert_nil options.verbose
    assert_equal false, options.quiet
    assert_equal false, options.dry_run
    assert_equal 'list', options.command
    assert_equal [], options.command_args
  end

  def test_parse_repeatable_v_sets_verbose_count
    options, = StowMan::CLI.parse(['-v', '-v', 'list'])

    assert_equal 2, options.verbose
  end

  def test_parse_explicit_verbose_overrides_v_count
    options, = StowMan::CLI.parse(['-v', '--verbose', '4', 'list'])

    assert_equal 4, options.verbose
  end

  def test_parse_config_quiet_dry_run_and_command_args
    options, = StowMan::CLI.parse(['--config', 'custom.yml', '--quiet', '--dry-run', 'add', 'nvim'])

    assert_equal 'custom.yml', options.config_path
    assert_equal true, options.quiet
    assert_equal true, options.dry_run
    assert_equal 'add', options.command
    assert_equal ['nvim'], options.command_args
  end
end
