# frozen_string_literal: true

module StowMan
  class Error < StandardError; end

  class UsageError < Error; end
  class ConfigError < Error; end
  class AppError < Error; end

  # Main generic error class for any issues related  to executing the stow command,
  # such as command not found, non-zero exit status, etc.
  class CommandError < Error
    attr_reader :command, :status, :stderr

    def initialize(message, command:, status:, stderr:)
      super(message)
      @command = command
      @status = status
      @stderr = stderr
    end
  end
end
