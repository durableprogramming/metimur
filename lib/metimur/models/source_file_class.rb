# frozen_string_literal: true

module Metimur
  module Models
    class SourceFileClass
      attr_reader :name, :source_file, :methods, :comments, :start_line, :end_line 
      attr_accessor :parent_node, :path

      def initialize(name:, source_file:, start_line:, end_line:)
        @name = name
        @source_file = source_file
        @methods = []
        @comments = []
        @start_line = start_line
        @end_line = end_line
      end

      def add_method(method)
        @methods << method
      end

      def add_comment(comment)
        @comments << comment
      end

      def metadata
        {
          name: name,
          start_line: start_line,
          end_line: end_line,
          methods_count: methods.count,
          comments_count: comments.count,
          path: path
        }
      end

      def to_s
        "#{name} (#{start_line}..#{end_line})"
      end

      def inspect
        "#<#{self.class} #{self}>"
      end

      def ==(other)
        return false unless other.is_a?(SourceFileClass)

        name == other.name &&
          source_file == other.source_file &&
          start_line == other.start_line &&
          end_line == other.end_line
      end

      def file_path
        source_file.path
      end

      def source_code
        source_file.read_lines(start_line..end_line)
      end

      def update_location(start_line:, end_line:)
        @start_line = start_line
        @end_line = end_line
      end

      def namespace
        name.split("::")[0..-2].join("::")
      end

      def simple_name
        name.split("::").last
      end
    end
  end
end
