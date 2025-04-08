# frozen_string_literal: true

module ActiveMcp
  class StdioConnection
    def initialize
      $stdout.sync = true
    end

    def read_next_message
      message = $stdin.gets&.chomp
      message.to_s.dup.force_encoding("UTF-8")
    end

    def send_message(message)
      message = message.to_s.dup.force_encoding("UTF-8")
      $stdout.binmode
      $stdout.write(message + "\n")
      $stdout.flush
    end
  end
end
