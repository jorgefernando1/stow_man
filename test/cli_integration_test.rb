require 'test_helper'
require 'tmpdir'
require 'stringio'

class CLIIntegrationTest < Minitest::Test
  def test_add_list_remove_flow
    Dir.mktmpdir do |workspace|
      target = File.join(workspace, 'target')
      Dir.mkdir(target)
      config_path = File.join(workspace, '.stow-man.yml')
      File.write(config_path, "target_dir: #{target}\n")

      add_out = StringIO.new
      add_err = StringIO.new
      add_code = StowMan::CLI.start(%w[add nvim], out: add_out, err: add_err, pwd: workspace)
      assert_equal 0, add_code
      assert Dir.exist?(File.join(workspace, 'nvim'))

      FileUtils.mkdir_p(File.join(workspace, 'nvim', '.config'))
      File.write(File.join(workspace, 'nvim', '.config', 'init.lua'), "-- test\n")
      StowMan::CLI.start(%w[relink nvim], out: StringIO.new, err: StringIO.new, pwd: workspace)

      list_out = StringIO.new
      list_err = StringIO.new
      list_code = StowMan::CLI.start(['list'], out: list_out, err: list_err, pwd: workspace)
      assert_equal 0, list_code
      assert_includes list_out.string.lines.map(&:strip), 'nvim'
      assert_equal '', list_err.string

      remove_out = StringIO.new
      remove_err = StringIO.new
      remove_code = StowMan::CLI.start(%w[remove nvim], out: remove_out, err: remove_err, pwd: workspace)
      assert_equal 0, remove_code
      refute Dir.exist?(File.join(workspace, 'nvim'))
      assert_equal '', remove_err.string
    end
  end

  def test_relink_all_flow
    Dir.mktmpdir do |workspace|
      target = File.join(workspace, 'target')
      Dir.mkdir(target)
      config_path = File.join(workspace, '.stow-man.yml')
      File.write(config_path, "target_dir: #{target}\n")

      %w[nvim zsh].each do |app|
        FileUtils.mkdir_p(File.join(workspace, app, '.config'))
        File.write(File.join(workspace, app, '.config', "#{app}.conf"), "set #{app}\n")
      end

      out = StringIO.new
      err = StringIO.new
      code = StowMan::CLI.start(['relink-all'], out: out, err: err, pwd: workspace)

      assert_equal 0, code
      assert_includes out.string, 'Relinked 2 app(s)'
      assert_equal '', err.string
      assert File.symlink?(File.join(target, '.config', 'nvim.conf'))
      assert File.symlink?(File.join(target, '.config', 'zsh.conf'))
    end
  end

  def test_config_error_exit_code
    Dir.mktmpdir do |workspace|
      out = StringIO.new
      err = StringIO.new

      code = StowMan::CLI.start(['list'], out: out, err: err, pwd: workspace)

      assert_equal 3, code
      assert_includes err.string, 'Config error'
    end
  end

  def test_usage_error_exit_code
    Dir.mktmpdir do |workspace|
      target = File.join(workspace, 'target')
      Dir.mkdir(target)
      File.write(File.join(workspace, '.stow-man.yml'), "target_dir: #{target}\n")

      out = StringIO.new
      err = StringIO.new
      code = StowMan::CLI.start(['add'], out: out, err: err, pwd: workspace)

      assert_equal 2, code
      assert_includes err.string, 'Usage error'
    end
  end

  def test_app_error_exit_code
    Dir.mktmpdir do |workspace|
      target = File.join(workspace, 'target')
      Dir.mkdir(target)
      File.write(File.join(workspace, '.stow-man.yml'), "target_dir: #{target}\n")

      out = StringIO.new
      err = StringIO.new
      code = StowMan::CLI.start(%w[remove missing], out: out, err: err, pwd: workspace)

      assert_equal 4, code
      assert_includes err.string, 'App error'
    end
  end

  def test_command_error_exit_code
    Dir.mktmpdir do |workspace|
      target = File.join(workspace, 'target')
      Dir.mkdir(target)
      File.write(File.join(workspace, '.stow-man.yml'), <<~YAML)
        target_dir: #{target}
        stow_bin: /does/not/exist/stow
      YAML

      out = StringIO.new
      err = StringIO.new
      code = StowMan::CLI.start(%w[add nvim], out: out, err: err, pwd: workspace)

      assert_equal 1, code
      assert_includes err.string, 'Command error'
    end
  end
end
