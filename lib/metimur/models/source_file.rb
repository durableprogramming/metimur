# frozen_string_literal: true

# The SourceFile class represents a Ruby source code file and provides functionality
# to track code structure elements like classes, modules, and methods. It manages
# the file's content and structural information, supports metadata extraction, and
# offers methods for locating specific elements within the file. This is a core model
# in the Metimur system that enables source code analysis and documentation.

module Metimur
  module Models
    class SourceFile
      attr_reader :path, :classes, :methods, :modules, :source_lines

      def initialize(path)
        @path = File.expand_path(path)
        @classes = []
        @methods = []
        @modules = []
        @source_lines = File.readlines(@path)
      end

      def add_class(klass)
        @classes << klass
      end

      def add_method(method)
        @methods << method
      end

      def add_module(mod)
        @modules << mod
      end

      def read_lines(range)
        @source_lines[range]
      end

      def total_lines
        @source_lines.size
      end

      def find_class(name)
        @classes.find { |klass| klass.name == name }
      end

      def find_method(name)
        @methods.find { |method| method.name == name }
      end

      def find_module(name)
        @modules.find { |mod| mod.name == name }
      end

      def to_h
        {
          path: @path,
          classes: @classes.map(&:metadata),
          methods: @methods.map(&:to_h),
          modules: @modules.map(&:metadata),
          total_lines: total_lines
        }
      end

      def ==(other)
        return false unless other.is_a?(SourceFile)

        path == other.path
      end

      def reload
        @source_lines = File.readlines(@path)
      end

      def relative_path(base_path)
        @path.sub("#{base_path}/", "")
      end

      def basename
        File.basename(@path)
      end

      def dirname
        File.dirname(@path)
      end

      def extension
        File.extname(@path)
      end

      def to_s
        "#{basename} (#{total_lines} lines)"
      end

      def inspect
        "#<#{self.class} #{self}>"
      end
    end
  end
end

# Copyright (c) 2025 Durable Programming, LLC. All rights reserved.
