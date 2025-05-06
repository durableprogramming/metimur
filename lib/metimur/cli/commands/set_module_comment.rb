# frozen_string_literal: true

# # The SetModuleComment command provides functionality to add or update documentation for modules in Ruby source files. It allows users to specify a module by name or line number and add either plain comments or YARD-style documentation. The command automatically handles the insertion of properly formatted comments above the target module definition, preserving existing code structure. It can find modules in nested hierarchies, supporting proper documentation of the module structure.

module Metimur
  module CLI
    module Commands
      class SetModuleComment < Dry::CLI::Command
        desc "Set or update a module comment"
        argument :path, type: :string, required: true, desc: "Path to Ruby source file"
        argument :module_name, type: :string, required: true, desc: "Name of the module to comment"
        argument :comment, type: :string, required: true, desc: "Comment text to add"
        option :line_number, type: :integer, desc: "Line number of the module (optional)"
        option :type, type: :string, default: "yard", values: %w[yard plain], desc: "Comment type (yard or plain)"
        example [
          "lib/example.rb MyModule 'This is a comment' # Add plain comment",
          "lib/example.rb MyModule '@author John Doe' --type=yard # Add YARD comment",
          "lib/example.rb MyModule 'New comment' --line-number=42 # Add comment at specific line"
        ]
        def call(path:, module_name:, comment:, line_number: nil, type: "yard", **)
          source_file = Metimur.parse_file(path)

          if line_number.nil?
            mod = find_module(source_file, module_name)
            raise Error, "Module '#{module_name}' not found in #{path}" unless mod

            line_number = mod.start_line
          end
          lines = File.readlines(path)

          case type
          when "yard"
            action = Actions::SetYardComment.new
            result = action.call(lines.join, line_number, comment)
            File.write(path, result.join("\n"))
          else
            action = Actions::SetFileHeaderComment.new(path, comment)
            action.call
          end
          puts "Comment updated successfully for module '#{module_name}'"
        rescue Errno::ENOENT
          puts "Error: File not found - #{path}"
          exit(1)
        rescue Metimur::Error => e
          puts "Error: #{e.message}"
          exit(1)
        end

        private

        def find_module(source_file, module_name)
          source_file.modules.find { |m| m.name == module_name } ||
            source_file.modules.flat_map(&:submodules).find { |m| m.name == module_name }
        end
      end
    end
  end
end

# Copyright (c) 2025 Durable Programming, LLC. All rights reserved.
