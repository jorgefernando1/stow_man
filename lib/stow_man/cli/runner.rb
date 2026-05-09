# frozen_string_literal: true

module StowMan
  class CLI
    # Runs a single CLI invocation: parses options, wires dependencies, dispatches the command.
    class Runner
      def initialize(argv, out:, err:, pwd:)
        @argv = argv
        @out = out
        @err = err
        @pwd = pwd
        @cli_parser = Parser.new(pwd: pwd)
      end

      def call
        execute
      rescue StandardError => e
        dispatch_error(e)
      end

      private

      def execute
        options, opts_parser = @cli_parser.parse(@argv)
        return show_version if options.show_version
        return show_help(opts_parser) if options.show_help || options.command.nil?
        return reject_unknown(options.command, opts_parser) unless COMMANDS.include?(options.command)

        execute_command(options)
        0
      end

      def execute_command(options)
        config = ConfigLoader.load(options.config_path)
        effective_verbose = options.verbose.nil? ? config.default_verbose : options.verbose
        runner = build_runner(config, effective_verbose, options.dry_run)
        manager = AppManager.new(package_root: @pwd, target_dir: config.target_dir, runner: runner)

        dispatcher = CommandDispatcher.new(manager: manager, out: @out, quiet: options.quiet)
        dispatcher.dispatch(options.command, options.command_args)
      end

      def dispatch_error(exception)
        case exception
        when OptionParser::ParseError then on_parse_error(exception)
        when UsageError then on_usage_error(exception)
        when ConfigError then on_config_error(exception)
        when AppError then on_app_error(exception)
        when CommandError then on_command_error(exception)
        else raise
        end
      end

      def show_version
        @out.puts("stow-man #{StowMan::VERSION}")
        0
      end

      def show_help(opts_parser)
        @out.puts(opts_parser)
        0
      end

      def reject_unknown(command, opts_parser)
        @err.puts("Unknown command: #{command}")
        @err.puts(opts_parser)
        2
      end

      def build_runner(config, verbose, dry_run)
        StowRunner.new(
          stow_bin: config.stow_bin,
          package_root: @pwd,
          target_dir: config.target_dir,
          verbose: verbose,
          dry_run: dry_run
        )
      end

      def on_parse_error(error)
        @err.puts("Argument error: #{error.message}")
        @err.puts(@cli_parser.help)
        2
      end

      def on_usage_error(error)
        @err.puts("Usage error: #{error.message}")
        2
      end

      def on_config_error(error)
        @err.puts("Config error: #{error.message}")
        3
      end

      def on_app_error(error)
        @err.puts("App error: #{error.message}")
        4
      end

      def on_command_error(error)
        @err.puts("Command error: #{error.message}")
        @err.puts(error.stderr) unless error.stderr.to_s.empty?
        1
      end
    end
  end
end
