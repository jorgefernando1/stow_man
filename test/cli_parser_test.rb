# frozen_string_literal: true

require 'test_helper'

class CLIParserTest < Minitest::Test
  def setup
    @parser = StowMan::CLI::Parser.new(pwd: '/tmp/dotfiles')
  end

  def test_defaults_and_command
    options, = @parser.parse(['list'])

    assert_equal '/tmp/dotfiles/.stow-man.yml', options.config_path
    assert_nil options.verbose
    assert_equal false, options.quiet
    assert_equal false, options.dry_run
    assert_equal 'list', options.command
    assert_equal [], options.command_args
    assert_equal false, options.show_help
    assert_equal false, options.show_version
  end

  def test_repeatable_v_sets_verbose_count
    options, = @parser.parse(['-v', '-v', 'list'])

    assert_equal 2, options.verbose
  end

  def test_single_v_sets_verbose_to_one
    options, = @parser.parse(['-v', 'list'])

    assert_equal 1, options.verbose
  end

  def test_explicit_verbose_overrides_v_count
    options, = @parser.parse(['-v', '--verbose', '4', 'list'])

    assert_equal 4, options.verbose
  end

  def test_explicit_verbose_zero_takes_precedence_over_v
    options, = @parser.parse(['-v', '--verbose', '0', 'list'])

    assert_equal 0, options.verbose
  end

  def test_config_quiet_dry_run_and_command_args
    options, = @parser.parse(['--config', 'custom.yml', '--quiet', '--dry-run', 'add', 'nvim'])

    assert_equal 'custom.yml', options.config_path
    assert_equal true, options.quiet
    assert_equal true, options.dry_run
    assert_equal 'add', options.command
    assert_equal ['nvim'], options.command_args
  end

  def test_short_config_flag
    options, = @parser.parse(['-c', 'my.yml', 'list'])

    assert_equal 'my.yml', options.config_path
  end

  def test_short_quiet_flag
    options, = @parser.parse(['-q', 'list'])

    assert_equal true, options.quiet
  end

  def test_help_flag_sets_show_help
    options, = @parser.parse(['--help'])

    assert_equal true, options.show_help
  end

  def test_short_help_flag
    options, = @parser.parse(['-h'])

    assert_equal true, options.show_help
  end

  def test_version_flag_sets_show_version
    options, = @parser.parse(['--version'])

    assert_equal true, options.show_version
  end

  def test_no_args_leaves_command_nil
    options, = @parser.parse([])

    assert_nil options.command
    assert_equal [], options.command_args
  end

  def test_extra_args_become_command_args
    options, = @parser.parse(['add', 'nvim', 'extra'])

    assert_equal 'add', options.command
    assert_equal ['nvim', 'extra'], options.command_args
  end

  def test_help_returns_usage_string
    text = @parser.help

    assert_includes text, 'Usage: stow-man'
    assert_includes text, 'Commands:'
    assert_includes text, 'Global options:'
  end

  def test_invalid_option_raises_parse_error
    assert_raises(OptionParser::ParseError) { @parser.parse(['--unknown-flag']) }
  end
end
