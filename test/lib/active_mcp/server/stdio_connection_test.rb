# frozen_string_literal: true

require "test_helper"
require "stringio"

module ActiveMcp
  class StdioConnectionTest < ActiveSupport::TestCase
    setup do
      @original_stdin = $stdin
      @original_stdout = $stdout
      @input = StringIO.new
      @output = StringIO.new
      $stdin = @input
      $stdout = @output
      @connection = StdioConnection.new
    end

    teardown do
      $stdin = @original_stdin
      $stdout = @original_stdout
    end

    test "read_next_message reads a line from stdin with UTF-8 encoding" do
      @input.puts "Message"
      @input.rewind

      message = @connection.read_next_message

      assert_equal "Message", message
      assert_equal Encoding::UTF_8, message.encoding
    end

    test "send_message writes message to stdout with UTF-8 encoding and newline" do
      @connection.send_message("Message")

      @output.rewind
      result = @output.read

      assert_equal "Message\n", result
      assert_equal Encoding::ASCII_8BIT, result.encoding
    end

    test "read_next_message returns empty string for nil input" do
      message = @connection.read_next_message

      assert_equal "", message
      assert_equal Encoding::UTF_8, message.encoding
    end

    test "send_message converts non-string objects to string" do
      @connection.send_message(123)

      @output.rewind
      result = @output.read

      assert_equal "123\n", result
      assert_equal Encoding::ASCII_8BIT, result.encoding
    end
  end
end
