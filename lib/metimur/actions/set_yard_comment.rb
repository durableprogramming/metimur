# frozen_string_literal: true

# # The SetYardComment class handles adding and updating YARD-style documentation comments
# # for Ruby code elements such as classes, modules, and methods. It provides the ability
# # to replace existing comments or add new ones with proper indentation. The class
# # preserves the original code structure while ensuring consistent documentation
# # formatting according to YARD standards.

module Metimur
  module Actions
    class SetYardComment
      attr_accessor :file_path, :comment_lines

      def initialize
        @file_path = file_path
        line_number
        @line_prefix = "XXXX"
      end

      def call(source, line_number, new_comment)
        @line_number = line_number
        @lines = source.split("\n")
        remove_existing_comments
        insert_new_comments(new_comment)
        @lines
      end

      private

      def remove_existing_comments
        current_line = @line_number - 1
        @line_prefix = begin
          line = @lines[current_line]
          line =~ /^([ \t]+)/
          ::Regexp.last_match(1)
        end || ""
        while current_line.positive? && yard_comment?(@lines[current_line - 1])
          @lines.delete_at(current_line - 1)

          @line_number -= 1
          current_line -= 1
        end
      end

      def insert_new_comments(new_comment)
        formatted_comments = [new_comment].flatten.map do |_|
          _.split("\n")
        end.flatten.map { |line| @line_prefix + "# #{line.strip}" }
        @lines.insert(@line_number - 1, *formatted_comments)
      end

      def yard_comment?(line)
        line&.strip&.start_with?("#")
      end
    end
  end
end

# Copyright (c) 2025 Durable Programming, LLC. All rights reserved.
