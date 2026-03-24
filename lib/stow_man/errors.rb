module StowMan
  class Error < StandardError; end

  class UsageError < Error; end
  class ConfigError < Error; end
  class AppError < Error; end

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
