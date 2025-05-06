# frozen_string_literal: true

# # Metimur - Ruby source code metadata utility
# # A library for parsing, analyzing, and manipulating Ruby source code metadata.
# # This is the main entry point for the Metimur library, providing methods for
# # parsing files, directories, and updating comments in Ruby source code.

module Metimur
  class Error < StandardError; end

  def self.parse_file(path)
    source_file = Models::SourceFile.new(path)
    parser = ParseSourceCode.new(source_file)
    parser.parse
  end

  def self.parse_directory(path)
    source_tree = Models::SourceTree.new(path)
    source_tree.files.each do |file|
      parser = ParseSourceCode.new(file)
      parser.parse
    end
    source_tree
  end

  def self.set_yard_comment(file_path, line_number, comment)
    action = Actions::SetYardComment.new
    lines = File.readlines(file_path)
    result = action.call(lines.join, line_number, comment)
    File.write(file_path, result.join("\n"))
  end

  def self.set_file_header_comment(file_path, comment)
    action = Actions::SetFileHeaderComment.new(file_path, comment)
    action.call
  end

  def self.set_file_footer_comment(file_path, comment)
    action = Actions::SetFileFooterComment.new(file_path, comment)
    action.call
  end
end

require_relative "metimur/version"
require_relative "metimur/parse_source_code"
require_relative "metimur/models/source_file"
require_relative "metimur/models/source_file_class"
require_relative "metimur/models/source_file_method"
require_relative "metimur/models/source_file_module"
require_relative "metimur/models/source_tree"
require_relative "metimur/actions/set_yard_comment"
require_relative "metimur/actions/set_file_header_comment"
require_relative "metimur/actions/set_file_footer_comment"
require_relative "metimur/cli"

# Copyright (c) 2025 Durable Programming, LLC. All rights reserved.
