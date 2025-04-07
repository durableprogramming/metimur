# frozen_string_literal: true

module Metimur
  module Models
    class SourceFileMethod
      attr_accessor :name, :start_line, :end_line, :visibility, :comments, :parameters, :path, :parent_node
      attr_reader :source_file

      def initialize(source_file, name, start_line = nil, end_line = nil)
        @source_file = source_file
        @name = name
        @start_line = start_line
        @end_line = end_line
        @visibility = :public
        @comments = []
        @parameters = []
        @path = []
      end

      def source
        return nil unless start_line && end_line

        source_file.source_lines[(start_line - 1)...(end_line)].join("\n")
      end

      def add_comment(comment)
        @comments << comment
      end

      def add_parameter(parameter)
        @parameters << parameter
      end

      def documented?
        !comments.empty?
      end

      def line_count
        return 0 unless start_line && end_line

        end_line - start_line + 1
      end

      def to_h
        {
          name: name,
          start_line: start_line,
          end_line: end_line,
          visibility: visibility,
          comments: comments,
          parameters: parameters,
          documented: documented?,
          line_count: line_count,
          path: path
        }
      end

      def ==(other)
        return false unless other.is_a?(SourceFileMethod)

        name == other.name &&
          start_line == other.start_line &&
          end_line == other.end_line &&
          visibility == other.visibility
      end
    end
  end
end
