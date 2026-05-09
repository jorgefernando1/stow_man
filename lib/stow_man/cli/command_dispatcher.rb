# frozen_string_literal: true

module StowMan
  class CLI
    # Routes CLI commands to the appropriate AppManager operation.
    class CommandDispatcher
      COMMAND_METHODS = {
        'add' => :run_add,
        'list' => :run_list,
        'remove' => :run_remove,
        'relink' => :run_relink,
        'relink-all' => :run_relink_all
      }.freeze

      def initialize(manager:, out:, quiet:)
        @manager = manager
        @out = out
        @quiet = quiet
      end

      def dispatch(command, args)
        handler = COMMAND_METHODS.fetch(command) { raise UsageError, "Unknown command: #{command}" }
        send(handler, args)
      end

      private

      def run_add(args)
        app = require_app_arg!(args, 'add')
        @manager.add(app)
        @out.puts("Added app '#{app}'") unless @quiet
      end

      def run_list(args)
        raise UsageError, 'list does not accept arguments' unless args.empty?

        @manager.list.each { |app| @out.puts(app) }
      end

      def run_remove(args)
        app = require_app_arg!(args, 'remove')
        @manager.remove(app)
        @out.puts("Removed app '#{app}'") unless @quiet
      end

      def run_relink(args)
        app = require_app_arg!(args, 'relink')
        @manager.relink(app)
        @out.puts("Relinked app '#{app}'") unless @quiet
      end

      def run_relink_all(args)
        raise UsageError, 'relink-all does not accept arguments' unless args.empty?

        apps = @manager.relink_all
        @out.puts("Relinked #{apps.length} app(s)") unless @quiet
      end

      def require_app_arg!(args, command)
        app = args.first
        raise UsageError, "#{command} requires APP argument" if app.nil? || app.empty?
        raise UsageError, "#{command} accepts only one APP argument" if args.length > 1

        app
      end
    end
  end
end
