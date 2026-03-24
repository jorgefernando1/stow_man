require 'yaml'

module StowMan
  class ConfigLoader
    Config = Struct.new(:target_dir, :stow_bin, :default_verbose, keyword_init: true)

    def self.load(path)
      data = begin
        YAML.load_file(path)
      rescue Errno::ENOENT
        raise ConfigError, "Config file not found: #{path}"
      rescue Psych::SyntaxError => e
        raise ConfigError, "Invalid YAML in #{path}: #{e.message}"
      end

      raise ConfigError, 'Config file must contain a YAML mapping' unless data.is_a?(Hash)

      target_dir = data['target_dir']
      stow_bin = data.fetch('stow_bin', 'stow')
      default_verbose = data.fetch('default_verbose', 0)

      validate_target_dir!(target_dir)
      validate_stow_bin!(stow_bin)
      validate_default_verbose!(default_verbose)

      Config.new(
        target_dir: File.expand_path(target_dir),
        stow_bin: stow_bin,
        default_verbose: default_verbose
      )
    end

    def self.validate_target_dir!(target_dir)
      raise ConfigError, 'Missing required config key: target_dir' if target_dir.nil? || target_dir.to_s.strip.empty?

      expanded = File.expand_path(target_dir)
      raise ConfigError, "target_dir does not exist: #{expanded}" unless Dir.exist?(expanded)
      raise ConfigError, "target_dir is not a directory: #{expanded}" unless File.directory?(expanded)
    end
    private_class_method :validate_target_dir!

    def self.validate_stow_bin!(stow_bin)
      return unless stow_bin.nil? || stow_bin.to_s.strip.empty?

      raise ConfigError, 'stow_bin must be a non-empty string'
    end
    private_class_method :validate_stow_bin!

    def self.validate_default_verbose!(value)
      return if value.is_a?(Integer) && value >= 0

      raise ConfigError, 'default_verbose must be an integer >= 0'
    end
    private_class_method :validate_default_verbose!
  end
end
