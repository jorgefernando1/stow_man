require 'test_helper'
require 'tmpdir'

class StowRunnerTest < Minitest::Test
  def test_dry_run_stow_returns_command_string
    Dir.mktmpdir do |dir|
      runner = StowMan::StowRunner.new(
        stow_bin: 'stow',
        package_root: dir,
        target_dir: dir,
        verbose: 2,
        dry_run: true
      )

      result = runner.stow('nvim')

      assert_equal 0, result.status
      assert_includes result.stdout, 'stow'
      assert_includes result.stdout, '-d'
      assert_includes result.stdout, '-t'
      assert_includes result.stdout, '-vv'
      assert_includes result.stdout, 'nvim'
    end
  end

  def test_dry_run_unstow_includes_delete_flag
    Dir.mktmpdir do |dir|
      runner = StowMan::StowRunner.new(
        stow_bin: 'stow',
        package_root: dir,
        target_dir: dir,
        verbose: 0,
        dry_run: true
      )

      result = runner.unstow('zsh')

      assert_equal 0, result.status
      assert_includes result.stdout, '-D'
      assert_includes result.stdout, 'zsh'
    end
  end

  def test_dry_run_relink_includes_restow_flag
    Dir.mktmpdir do |dir|
      runner = StowMan::StowRunner.new(
        stow_bin: 'stow',
        package_root: dir,
        target_dir: dir,
        verbose: 1,
        dry_run: true
      )

      result = runner.relink('tmux')

      assert_equal 0, result.status
      assert_includes result.stdout, '-R'
      assert_includes result.stdout, '-v'
      assert_includes result.stdout, 'tmux'
    end
  end
end
