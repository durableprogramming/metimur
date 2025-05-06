# frozen_string_literal: true

# The SetFileFooterComment class handles appending comments to the end of Ruby source files.
# It supports adding standardized footer comments such as copyright notices or
# license information by removing any existing footer comments and adding new ones.
# This ensures consistent footer styling across a codebase.

module Metimur
  module Actions
    class SetFileFooterComment
      def initialize(file_path, comment_lines)
        @file_path = file_path
        @comment_lines = Array(comment_lines)
        @source_file = Models::SourceFile.new(file_path)
      end

      def call
        lines = File.readlines(@file_path)
        remove_existing_footer_comments(lines)
        append_new_footer_comments(lines)
        write_file(lines)
      end

      private

      def remove_existing_footer_comments(lines)
        lines.pop while !lines.empty? && comment_line?(lines.last)
      end

      def append_new_footer_comments(lines)
        lines << "\n" unless lines.empty? || lines.last.strip.empty?
        @comment_lines.each do |line|
          lines << "# #{line}\n"
        end
      end

      def comment_line?(line)
        line.strip.start_with?("#")
      end

      def write_file(lines)
        File.write(@file_path, lines.join)
      end
    end
  end
end

# Copyright (c) 2025 Durable Programming, LLC. All rights reserved.
