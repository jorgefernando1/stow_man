require 'pathname'
require 'fileutils'

module StowMan
  class AppManager
    def initialize(package_root:, target_dir:, runner:)
      @package_root = File.expand_path(package_root)
      @target_dir = File.expand_path(target_dir)
      @runner = runner
    end

    def add(app)
      validate_app_name!(app)
      app_dir = app_path(app)
      if File.exist?(app_dir) && !File.directory?(app_dir)
        raise AppError, "App path exists but is not a directory: #{app}"
      end

      Dir.mkdir(app_dir) unless Dir.exist?(app_dir)
      @runner.stow(app)
    end

    def list
      apps = []
      Dir.glob(File.join(@target_dir, '**', '*'), File::FNM_DOTMATCH).each do |entry|
        next if ['.', '..'].include?(File.basename(entry))
        next unless File.symlink?(entry)

        target = resolve_symlink_target(entry)
        next unless target

        app_name = app_from_target(target)
        apps << app_name if app_name
      end

      apps.uniq.sort
    end

    def remove(app)
      validate_app_name!(app)
      app_dir = app_path(app)
      raise AppError, "App not found: #{app}" unless Dir.exist?(app_dir)
      raise AppError, "Refusing to remove symlinked app dir: #{app}" if File.symlink?(app_dir)

      @runner.unstow(app)
      FileUtils.rm_rf(app_dir)
      true
    end

    def relink(app)
      validate_app_name!(app)
      app_dir = app_path(app)
      raise AppError, "App not found: #{app}" unless Dir.exist?(app_dir)

      @runner.relink(app)
    end

    def relink_all
      apps = Dir.children(@package_root)
                .sort
                .select { |entry| File.directory?(File.join(@package_root, entry)) }
                .reject { |entry| entry.start_with?('.') }
                .reject { |entry| File.expand_path(File.join(@package_root, entry)) == @target_dir }

      apps.each { |app| @runner.relink(app) }
      apps
    end

    private

    def app_path(app)
      File.join(@package_root, app)
    end

    def validate_app_name!(app)
      if app.nil? || app.empty? || app.include?('/') || app.include?('\\') || app == '.' || app == '..' || app.start_with?('~')
        raise AppError, "Invalid app name: #{app.inspect}"
      end
    end

    def resolve_symlink_target(symlink_path)
      raw_target = File.readlink(symlink_path)
      absolute_target = if Pathname.new(raw_target).absolute?
                          raw_target
                        else
                          File.expand_path(raw_target, File.dirname(symlink_path))
                        end
      File.expand_path(absolute_target)
    rescue Errno::ENOENT
      nil
    end

    def app_from_target(target)
      root_with_sep = @package_root.end_with?(File::SEPARATOR) ? @package_root : "#{@package_root}#{File::SEPARATOR}"
      return nil unless target.start_with?(root_with_sep)

      relative = target.delete_prefix(root_with_sep)
      app = relative.split(File::SEPARATOR).first
      return nil if app.nil? || app.empty?

      app
    end
  end
end
