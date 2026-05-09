# frozen_string_literal: true

require 'optparse'
require_relative 'cli/parser'
require_relative 'cli/command_dispatcher'
require_relative 'cli/runner'

module StowMan
  # Entry point for the stow-man CLI; delegates execution to Runner.
  class CLI
    DEFAULT_CONFIG_FILE = '.stow-man.yml'
    COMMANDS = %w[add list remove relink relink-all].freeze

    Options = Struct.new(
      :config_path,
      :verbose,
      :quiet,
      :dry_run,
      :command,
      :command_args,
      :show_help,
      :show_version,
      keyword_init: true
    )

    def self.start(argv, out: $stdout, err: $stderr, pwd: Dir.pwd)
      Runner.new(argv, out: out, err: err, pwd: pwd).call
    end
  end
end
