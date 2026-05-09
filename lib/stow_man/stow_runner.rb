# frozen_string_literal: true

require 'open3'
require 'shellwords'

module StowMan
  # Class responsible to actually execute a stow command in the terminal.
  class StowRunner
    CommandResult = Data.define(:status, :stdout, :stderr)

    def initialize(stow_bin:, package_root:, target_dir:, verbose:, dry_run: false)
      @stow_bin = stow_bin
      @package_root = package_root
      @target_dir = target_dir
      @verbose = verbose
      @dry_run = dry_run
    end

    def stow(app)
      run_command(base_command + [app])
    end

    def unstow(app)
      run_command(base_command + ['-D', app])
    end

    def relink(app)
      run_command(base_command + ['-R', app])
    end

    private

    def base_command
      command = [@stow_bin, '-d', @package_root, '-t', @target_dir]
      command << "-#{'v' * @verbose}" if @verbose.to_i.positive?
      command
    end

    def run_command(command)
      return dry_run_result(command) if @dry_run

      execute_in_shell!(command)
    rescue Errno::ENOENT => e
      raise CommandError.new(
        "Command failed to start: #{command.first} (#{e.message})",
        command: command,
        status: 127,
        stderr: e.message
      )
    end

    def dry_run_result(command)
      CommandResult.new(status: 0, stdout: "DRY-RUN: #{command_string(command)}", stderr: '')
    end

    def execute_in_shell!(command)
      stdout, stderr, status = Open3.capture3(*command)
      return CommandResult.new(status: status.exitstatus, stdout: stdout, stderr: stderr) if status.success?

      raise CommandError.new(
        "Command failed with status #{status.exitstatus}: #{command_string(command)}",
        command: command,
        status: status.exitstatus,
        stderr: stderr
      )
    end

    def command_string(command)
      command.map { |part| Shellwords.escape(part) }.join(' ')
    end
  end
end
