# frozen_string_literal: true

# The SourceFileModule model represents a module within a Ruby source file. It tracks the module name, methods, classes, submodules, and location within the file. This class provides functionality to manage module metadata, including adding methods and classes, handling comments, and determining relationships with other code elements. It supports hierarchical representation of Ruby modules with full namespace awareness and position tracking for precise source navigation.

module Metimur
  module Models
    class SourceFileModule
      attr_reader :name, :source_file, :methods, :comments, :start_line, :end_line, :classes, :submodules
      attr_accessor :parent_node, :path

      def initialize(name:, source_file:, start_line:, end_line:)
        @name = name
        @source_file = source_file
        @methods = []
        @comments = []
        @classes = []
        @submodules = []
        @start_line = start_line
        @end_line = end_line
      end

      def add_method(method)
        @methods << method
      end

      def add_comment(comment)
        @comments << comment
      end

      def add_class(klass)
        @classes << klass
      end

      def add_submodule(submodule)
        @submodules << submodule
      end

      def metadata
        {
          name: name,
          start_line: start_line,
          end_line: end_line,
          methods_count: methods.count,
          comments_count: comments.count,
          classes_count: classes.count,
          submodules_count: submodules.count
        }
      end

      def to_s
        "#{name} (#{start_line}..#{end_line})"
      end

      def inspect
        "#<#{self.class} #{self}>"
      end

      def ==(other)
        return false unless other.is_a?(SourceFileModule)

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

      def full_name
        return name if namespace.empty?

        "#{namespace}::#{simple_name}"
      end
    end
  end
end

# Copyright (c) 2025 Durable Programming, LLC. All rights reserved.
