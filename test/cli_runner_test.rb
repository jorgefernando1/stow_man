# frozen_string_literal: true

require 'test_helper'
require 'tmpdir'
require 'stringio'

class CLIRunnerTest < Minitest::Test
  def runner(argv, out:, err:, pwd: '/tmp')
    StowMan::CLI::Runner.new(argv, out: out, err: err, pwd: pwd)
  end

  def test_show_version
    out = StringIO.new
    err = StringIO.new

    code = runner(['--version'], out: out, err: err).call

    assert_equal 0, code
    assert_equal "stow-man #{StowMan::VERSION}\n", out.string
    assert_empty err.string
  end

  def test_show_help_flag
    out = StringIO.new
    err = StringIO.new

    code = runner(['--help'], out: out, err: err).call

    assert_equal 0, code
    assert_includes out.string, 'Usage: stow-man'
    assert_empty err.string
  end

  def test_no_command_shows_help
    out = StringIO.new
    err = StringIO.new

    code = runner([], out: out, err: err).call

    assert_equal 0, code
    assert_includes out.string, 'Commands:'
    assert_empty err.string
  end

  def test_unknown_command_shows_error_and_help
    out = StringIO.new
    err = StringIO.new

    code = runner(['frobnicate'], out: out, err: err).call

    assert_equal 2, code
    assert_empty out.string
    assert_includes err.string, 'Unknown command: frobnicate'
    assert_includes err.string, 'Usage: stow-man'
  end

  def test_parse_error_returns_exit_2_with_help
    out = StringIO.new
    err = StringIO.new

    code = runner(['--not-a-real-flag'], out: out, err: err).call

    assert_equal 2, code
    assert_includes err.string, 'Argument error:'
    assert_includes err.string, 'Usage: stow-man'
  end

  def test_config_error_returns_exit_3
    Dir.mktmpdir do |workspace|
      out = StringIO.new
      err = StringIO.new

      code = runner(['list'], out: out, err: err, pwd: workspace).call

      assert_equal 3, code
      assert_includes err.string, 'Config error'
    end
  end

  def test_usage_error_returns_exit_2
    Dir.mktmpdir do |workspace|
      target = File.join(workspace, 'target')
      Dir.mkdir(target)
      File.write(File.join(workspace, '.stow-man.yml'), "target_dir: #{target}\n")

      out = StringIO.new
      err = StringIO.new

      code = runner(['add'], out: out, err: err, pwd: workspace).call

      assert_equal 2, code
      assert_includes err.string, 'Usage error'
    end
  end

  def test_app_error_returns_exit_4
    Dir.mktmpdir do |workspace|
      target = File.join(workspace, 'target')
      Dir.mkdir(target)
      File.write(File.join(workspace, '.stow-man.yml'), "target_dir: #{target}\n")

      out = StringIO.new
      err = StringIO.new

      code = runner(['remove', 'missing'], out: out, err: err, pwd: workspace).call

      assert_equal 4, code
      assert_includes err.string, 'App error'
    end
  end

  def test_command_error_returns_exit_1
    Dir.mktmpdir do |workspace|
      target = File.join(workspace, 'target')
      Dir.mkdir(target)
      File.write(File.join(workspace, '.stow-man.yml'), <<~YAML)
        target_dir: #{target}
        stow_bin: /does/not/exist/stow
      YAML

      out = StringIO.new
      err = StringIO.new

      code = runner(['add', 'nvim'], out: out, err: err, pwd: workspace).call

      assert_equal 1, code
      assert_includes err.string, 'Command error'
    end
  end

  def test_successful_command_returns_exit_0
    Dir.mktmpdir do |workspace|
      target = File.join(workspace, 'target')
      Dir.mkdir(target)
      File.write(File.join(workspace, '.stow-man.yml'), "target_dir: #{target}\n")

      out = StringIO.new
      err = StringIO.new

      code = runner(['add', 'nvim'], out: out, err: err, pwd: workspace).call

      assert_equal 0, code
      assert_empty err.string
    end
  end
end
