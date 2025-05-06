# frozen_string_literal: true

# The SetFileHeaderComment class handles adding comments to the beginning of Ruby source files.
# It supports adding standardized header comments such as copyright notices or
# license information by removing any existing header comments and adding new ones.
# This ensures consistent header styling across a codebase.

module Metimur
  module Actions
    class SetFileHeaderComment
      def initialize(file_path, comment_lines)
        @file_path = file_path
        @comment_lines = Array(comment_lines)
        @source_file = Models::SourceFile.new(file_path)
      end

      def call
        lines = File.readlines(@file_path)
        remove_existing_header_comments(lines)
        insert_new_header_comments(lines)
        write_file(lines)
      end

      private

      def remove_existing_header_comments(lines)
        lines.shift while !lines.empty? && comment_line?(lines.first)
      end

      def insert_new_header_comments(lines)
        formatted_comments = @comment_lines.map { |line| "# #{line}\n" }
        formatted_comments << "\n" unless formatted_comments.empty?
        lines.unshift(*formatted_comments)
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
