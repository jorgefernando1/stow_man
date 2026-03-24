require 'optparse'

module StowMan
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
      options, parser = parse(argv, pwd: pwd)

      if options.show_version
        out.puts("stow-man #{StowMan::VERSION}")
        return 0
      end

      if options.show_help || options.command.nil?
        out.puts(parser)
        return 0
      end

      unless COMMANDS.include?(options.command)
        err.puts("Unknown command: #{options.command}")
        err.puts(parser)
        return 2
      end

      0
    rescue OptionParser::ParseError => e
      err.puts("Argument error: #{e.message}")
      err.puts(help_text)
      2
    end

    def self.parse(argv, pwd: Dir.pwd)
      options = Options.new(
        config_path: File.join(pwd, DEFAULT_CONFIG_FILE),
        verbose: nil,
        quiet: false,
        dry_run: false,
        command: nil,
        command_args: [],
        show_help: false,
        show_version: false
      )

      verbose_count = 0
      explicit_verbose = false
      parser = option_parser(options, verbose_count_ref: -> { verbose_count }, verbose_count_set: lambda { |v|
        verbose_count = v
      }, explicit_verbose_set: lambda {
           explicit_verbose = true
         })

      remaining = argv.dup
      parser.order!(remaining)

      options.command = remaining.shift
      options.command_args = remaining
      options.verbose = verbose_count if !explicit_verbose && verbose_count.positive?

      [options, parser]
    end

    def self.help_text
      option_parser(
        Options.new,
        verbose_count_ref: -> { 0 },
        verbose_count_set: ->(_v) {},
        explicit_verbose_set: -> {}
      ).to_s
    end

    def self.option_parser(options, verbose_count_ref:, verbose_count_set:, explicit_verbose_set:)
      OptionParser.new do |opts|
        opts.banner = 'Usage: stow-man [global options] COMMAND [args]'

        opts.separator('')
        opts.separator('Commands:')
        opts.separator('    add APP       Create app folder and stow it')
        opts.separator('    list          List currently linked apps')
        opts.separator('    remove APP    Unstow app and delete app folder')
        opts.separator('    relink APP    Re-stow one app')
        opts.separator('    relink-all    Re-stow all apps in current directory')

        opts.separator('')
        opts.separator('Global options:')
        opts.on('-c', '--config PATH', 'Path to YAML config (default: ./.stow-man.yml)') do |path|
          options.config_path = path
        end

        opts.on('-v', 'Increase verbosity by 1 (repeatable)') do
          verbose_count_set.call(verbose_count_ref.call + 1)
        end

        opts.on('--verbose N', Integer, 'Set explicit verbosity level') do |value|
          options.verbose = value
          explicit_verbose_set.call
        end

        opts.on('-q', '--quiet', 'Suppress non-error output') do
          options.quiet = true
        end

        opts.on('--dry-run', 'Print actions without executing') do
          options.dry_run = true
        end

        opts.on('-h', '--help', 'Show this help') do
          options.show_help = true
        end

        opts.on('--version', 'Show version') do
          options.show_version = true
        end
      end
    end
    private_class_method :option_parser
  end
end
