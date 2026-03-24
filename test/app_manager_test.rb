require 'test_helper'
require 'tmpdir'

class AppManagerTest < Minitest::Test
  FakeRunner = Struct.new(:calls) do
    def stow(app)
      calls << [:stow, app]
      true
    end

    def unstow(app)
      calls << [:unstow, app]
      true
    end

    def relink(app)
      calls << [:relink, app]
      true
    end
  end

  def test_add_creates_app_dir_and_stows
    Dir.mktmpdir do |root|
      target = File.join(root, 'target')
      Dir.mkdir(target)
      runner = FakeRunner.new([])
      manager = StowMan::AppManager.new(package_root: root, target_dir: target, runner: runner)

      manager.add('nvim')

      assert Dir.exist?(File.join(root, 'nvim'))
      assert_equal [[:stow, 'nvim']], runner.calls
    end
  end

  def test_list_returns_apps_for_symlinks_under_root
    Dir.mktmpdir do |root|
      target = File.join(root, 'target')
      Dir.mkdir(target)
      app_dir = File.join(root, 'nvim', '.config')
      FileUtils.mkdir_p(app_dir)
      source_file = File.join(app_dir, 'init.lua')
      File.write(source_file, "-- config\n")

      target_config_dir = File.join(target, '.config')
      Dir.mkdir(target_config_dir)
      File.symlink(source_file, File.join(target_config_dir, 'init.lua'))

      runner = FakeRunner.new([])
      manager = StowMan::AppManager.new(package_root: root, target_dir: target, runner: runner)

      assert_equal ['nvim'], manager.list
    end
  end

  def test_remove_unstows_and_deletes_dir
    Dir.mktmpdir do |root|
      target = File.join(root, 'target')
      Dir.mkdir(target)
      Dir.mkdir(File.join(root, 'zsh'))
      runner = FakeRunner.new([])
      manager = StowMan::AppManager.new(package_root: root, target_dir: target, runner: runner)

      manager.remove('zsh')

      refute Dir.exist?(File.join(root, 'zsh'))
      assert_equal [[:unstow, 'zsh']], runner.calls
    end
  end

  def test_relink_all_relinks_non_hidden_directories
    Dir.mktmpdir do |root|
      target = File.join(root, 'target')
      Dir.mkdir(target)
      Dir.mkdir(File.join(root, 'nvim'))
      Dir.mkdir(File.join(root, 'zsh'))
      Dir.mkdir(File.join(root, '.git'))
      runner = FakeRunner.new([])
      manager = StowMan::AppManager.new(package_root: root, target_dir: target, runner: runner)

      apps = manager.relink_all

      assert_equal %w[nvim zsh], apps
      assert_equal [[:relink, 'nvim'], [:relink, 'zsh']], runner.calls
    end
  end

  def test_rejects_invalid_app_name
    Dir.mktmpdir do |root|
      target = File.join(root, 'target')
      Dir.mkdir(target)
      runner = FakeRunner.new([])
      manager = StowMan::AppManager.new(package_root: root, target_dir: target, runner: runner)

      error = assert_raises(StowMan::AppError) { manager.add('../oops') }
      assert_includes error.message, 'Invalid app name'
    end
  end
end
