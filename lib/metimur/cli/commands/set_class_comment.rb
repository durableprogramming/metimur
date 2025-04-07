module Metimur
  module CLI
    module Commands
      class SetClassComment < Dry::CLI::Command
        desc "Set or update a class comment"
        argument :path, type: :string, required: true, desc: "Path to Ruby source file"
        argument :class_name, type: :string, required: true, desc: "Name of the class to comment"
        argument :comment, type: :string, required: true, desc: "Comment text to add"
        option :line_number, type: :integer, desc: "Line number of the class (optional)"
        option :type, type: :string, default: "yard", values: %w[yard plain], desc: "Comment type (yard or plain)"

        example [
          "lib/example.rb MyClass 'This is a comment' # Add plain comment",
          "lib/example.rb MyClass '@author John Doe' --type=yard # Add YARD comment",
          "lib/example.rb MyClass 'New comment' --line-number=42 # Add comment at specific line"
        ]

        def call(path:, class_name:, comment:, line_number: nil, type: "yard", **)
          begin
            source_file = Metimur.parse_file(path)
            
            if line_number.nil?
              klass = find_class(source_file, class_name)
              raise Error, "Class '#{class_name}' not found in #{path}" unless klass
              line_number = klass.start_line
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

            puts "Comment updated successfully for class '#{class_name}'"
          rescue Errno::ENOENT
            puts "Error: File not found - #{path}"
            exit(1)
          rescue Metimur::Error => e
            puts "Error: #{e.message}"
            exit(1)
          end
        end

        private

        def find_class(source_file, class_name)
          source_file.classes.find { |k| k.name == class_name } ||
            source_file.modules.flat_map(&:classes).find { |k| k.name == class_name }
        end
      end
    end
  end
end
