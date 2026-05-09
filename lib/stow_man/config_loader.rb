# frozen_string_literal: true

require 'yaml'

module StowMan
  # Class responsible to load and validate the configiration file for StowMan
  class ConfigLoader
    Config = Data.define(:target_dir, :stow_bin, :default_verbose)

    # Load the Config file from the given path and return a Config struct
    # @param path [String] the path to the YAML config file
    # @return [StowMan::Config] the loaded configuration
    def self.load(path)
      new(path).load
    end

    def initialize(path)
      @path = path
    end

    def load
      data = load_file
      raise ConfigError, 'Config file must contain a YAML mapping' unless data.is_a?(Hash)

      extract_values(data) => { target_dir:, stow_bin:, default_verbose: }
      perform_config_validations(target_dir, stow_bin, default_verbose)

      Config.new(
        target_dir: File.expand_path(target_dir),
        stow_bin: stow_bin,
        default_verbose: default_verbose
      )
    end

    private

    attr_reader :path

    def load_file
      YAML.load_file(path)
    rescue Errno::ENOENT
      raise ConfigError, "Config file not found: #{path}"
    rescue Psynch::SyntaxError => e
      raise ConfigError, "Invalid YAML in #{path}: #{e.message}"
    end

    def extract_values(file_data)
      {
        target_dir: file_data['target_dir'],
        stow_bin: file_data.fetch('stow_bin', 'stow'),
        default_verbose: file_data.fetch('default_verbose', 0)
      }
    end

    def perform_config_validations(target_dir, stow_bin, default_verbose)
      validate_target_dir!(target_dir)
      validate_stow_bin!(stow_bin)
      validate_default_verbose!(default_verbose)
    end

    def validate_target_dir!(target_dir)
      raise ConfigError, 'Missing required config key: target_dir' if target_dir.nil? || target_dir.to_s.strip.empty?

      expanded = File.expand_path(target_dir)
      raise ConfigError, "target_dir does not exist: #{expanded}" unless Dir.exist?(expanded)
      raise ConfigError, "target_dir is not a directory: #{expanded}" unless File.directory?(expanded)
    end

    def validate_stow_bin!(stow_bin)
      return unless stow_bin.nil? || stow_bin.to_s.strip.empty?

      raise ConfigError, 'stow_bin must be a non-empty string'
    end

    def validate_default_verbose!(value)
      return if value.is_a?(Integer) && value >= 0

      raise ConfigError, 'default_verbose must be an integer >= 0'
    end
  end
end
