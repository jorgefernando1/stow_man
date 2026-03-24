require 'test_helper'
require 'tmpdir'

class ConfigLoaderTest < Minitest::Test
  def test_loads_valid_config_with_defaults
    Dir.mktmpdir do |dir|
      target = File.join(dir, 'target')
      Dir.mkdir(target)
      config_path = File.join(dir, '.stow-man.yml')
      File.write(config_path, "target_dir: #{target}\n")

      config = StowMan::ConfigLoader.load(config_path)

      assert_equal target, config.target_dir
      assert_equal 'stow', config.stow_bin
      assert_equal 0, config.default_verbose
    end
  end

  def test_loads_valid_config_with_all_values
    Dir.mktmpdir do |dir|
      target = File.join(dir, 'target')
      Dir.mkdir(target)
      config_path = File.join(dir, '.stow-man.yml')
      File.write(config_path, <<~YAML)
        target_dir: #{target}
        stow_bin: /usr/bin/stow
        default_verbose: 2
      YAML

      config = StowMan::ConfigLoader.load(config_path)

      assert_equal target, config.target_dir
      assert_equal '/usr/bin/stow', config.stow_bin
      assert_equal 2, config.default_verbose
    end
  end

  def test_raises_for_missing_target_dir
    Dir.mktmpdir do |dir|
      config_path = File.join(dir, '.stow-man.yml')
      File.write(config_path, "stow_bin: stow\n")

      error = assert_raises(StowMan::ConfigError) { StowMan::ConfigLoader.load(config_path) }
      assert_includes error.message, 'target_dir'
    end
  end

  def test_raises_for_invalid_default_verbose
    Dir.mktmpdir do |dir|
      target = File.join(dir, 'target')
      Dir.mkdir(target)
      config_path = File.join(dir, '.stow-man.yml')
      File.write(config_path, <<~YAML)
        target_dir: #{target}
        default_verbose: noisy
      YAML

      error = assert_raises(StowMan::ConfigError) { StowMan::ConfigLoader.load(config_path) }
      assert_includes error.message, 'default_verbose'
    end
  end
end
