module Metimur
  module CLI
    module Commands
      class SetMethodComment < Dry::CLI::Command
        desc "Set or update a method comment"

        argument :path, type: :string, required: true, desc: "Path to Ruby source file"
        argument :method_name, type: :string, required: true, desc: "Name of the method to comment"
        argument :comment, type: :string, required: true, desc: "Comment text to add"

        option :line_number, type: :integer, desc: "Line number of the method (optional)"
        option :type, type: :string, default: "yard", values: %w[yard plain], desc: "Comment type (yard or plain)"

        example [
          "lib/example.rb my_method 'This is a comment' # Add plain comment",
          "lib/example.rb my_method '@param name [String] The name' --type=yard # Add YARD comment",
          "lib/example.rb my_method 'New comment' --line-number=42 # Add comment at specific line"
        ]

        def call(path:, method_name:, comment:, line_number: nil, type: "yard", **)
          begin
            source_file = Metimur.parse_file(path)
            
            if line_number.nil?
              method = find_method(source_file, method_name)
              raise Error, "Method '#{method_name}' not found in #{path}" unless method
              line_number = method.start_line
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

            puts "Comment updated successfully for method '#{method_name}'"
          rescue Errno::ENOENT
            puts "Error: File not found - #{path}"
            exit(1)
          rescue Metimur::Error => e
            puts "Error: #{e.message}"
            exit(1)
          end
        end

        private

        def find_method(source_file, method_name)
          source_file.methods.find { |m| m.name == method_name } ||
            source_file.classes.flat_map(&:methods).find { |m| m.name == method_name } ||
            source_file.modules.flat_map(&:methods).find { |m| m.name == method_name }
        end
      end
    end
  end
end
