# frozen_string_literal: true

require 'optparse'

module StowMan
  class CLI
    # Parses CLI arguments into an Options struct.
    class Parser
      VerboseTracker = Struct.new(:level, :explicit) do
        def increment!
          self.level += 1
        end

        def set_explicit!
          self.explicit = true
        end

        def resolved
          explicit ? nil : level.nonzero?
        end
      end

      def initialize(pwd: Dir.pwd)
        @default_config_path = File.join(pwd, DEFAULT_CONFIG_FILE)
      end

      def parse(argv)
        options = build_default_options
        tracker = VerboseTracker.new(0, false)
        opts_parser = build_option_parser(options, tracker)
        remaining = argv.dup
        opts_parser.order!(remaining)
        options.command = remaining.shift
        options.command_args = remaining
        options.verbose ||= tracker.resolved
        [options, opts_parser]
      end

      def help
        build_option_parser(Options.new, VerboseTracker.new(0, false)).to_s
      end

      private

      def build_default_options
        Options.new(
          config_path: @default_config_path,
          verbose: nil,
          quiet: false,
          dry_run: false,
          command: nil,
          command_args: [],
          show_help: false,
          show_version: false
        )
      end

      def build_option_parser(options, tracker)
        OptionParser.new do |opts|
          opts.banner = 'Usage: stow-man [global options] COMMAND [args]'
          define_commands_section(opts)
          define_global_options(opts, options, tracker)
        end
      end

      def define_commands_section(opts)
        opts.separator('')
        opts.separator('Commands:')
        opts.separator('    add APP       Create app folder and stow it')
        opts.separator('    list          List currently linked apps')
        opts.separator('    remove APP    Unstow app and delete app folder')
        opts.separator('    relink APP    Re-stow one app')
        opts.separator('    relink-all    Re-stow all apps in current directory')
      end

      def define_global_options(opts, options, tracker)
        opts.separator('')
        opts.separator('Global options:')
        opts.on('-c', '--config PATH', 'Path to YAML config (default: ./.stow-man.yml)') do |path|
          options.config_path = path
        end
        define_verbose_options(opts, options, tracker)
        define_behavior_options(opts, options)
      end

      def define_verbose_options(opts, options, tracker)
        opts.on('-v', 'Increase verbosity by 1 (repeatable)') { tracker.increment! }
        opts.on('--verbose N', Integer, 'Set explicit verbosity level') do |value|
          options.verbose = value
          tracker.set_explicit!
        end
      end

      def define_behavior_options(opts, options)
        opts.on('-q', '--quiet', 'Suppress non-error output') { options.quiet = true }
        opts.on('--dry-run', 'Print actions without executing') { options.dry_run = true }
        opts.on('-h', '--help', 'Show this help') { options.show_help = true }
        opts.on('--version', 'Show version') { options.show_version = true }
      end
    end
  end
end
