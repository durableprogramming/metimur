# frozen_string_literal: true

# The SourceTree model represents a collection of Ruby source files within a directory structure. It manages file discovery, tracking, and analysis at the project level. This class provides methods for finding files by class or method name, calculating code statistics, and managing the hierarchical relationships between files. It serves as the entry point for whole-project analysis, enabling operations across the entire codebase rather than on individual files.

module Metimur
  module Models
    class SourceTree
      attr_reader :root_path, :files

      def initialize(root_path)
        @root_path = File.expand_path(root_path)
        @files = []
        build_tree
      end

      def build_tree
        Dir.glob(File.join(@root_path, "**", "*.rb")).each do |file_path|
          @files << SourceFile.new(file_path)
        end
      end

      def find_file(path)
        @files.find { |file| file.path == path }
      end

      def find_files_by_class(class_name)
        @files.select { |file| file.classes.any? { |klass| klass.name == class_name } }
      end

      def find_files_by_method(method_name)
        @files.select { |file| file.methods.any? { |method| method.name == method_name } }
      end

      def total_classes
        @files.sum { |file| file.classes.count }
      end

      def total_methods
        @files.sum { |file| file.methods.count }
      end

      def total_lines
        @files.sum(&:total_lines)
      end

      def to_h
        {
          root_path: @root_path,
          files: @files.map(&:to_h),
          statistics: {
            total_files: @files.count,
            total_classes: total_classes,
            total_methods: total_methods,
            total_lines: total_lines
          }
        }
      end

      def reload
        @files.clear
        build_tree
      end

      private

      def relative_path(path)
        path.sub("#{@root_path}/", "")
      end
    end
  end
end

# Copyright (c) 2025 Durable Programming, LLC. All rights reserved.
