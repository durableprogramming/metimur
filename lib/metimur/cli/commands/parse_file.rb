require 'json'

module Metimur
  module CLI
    module Commands
      class ParseFile < Dry::CLI::Command
        desc "Parse a Ruby source file and display its metadata"

        argument :path, type: :string, required: true, desc: "Path to Ruby source file"
        option :format, type: :string, default: "text", values: %w[text json], desc: "Output format (text or json)"
        option :details, type: :boolean, default: false, desc: "Show detailed information"

        example [
          "lib/example.rb                    # Parse file with default text output",
          "lib/example.rb --format=json      # Parse file with JSON output",
          "lib/example.rb --details          # Parse file with detailed information"
        ]

        def call(path:, format: "text", details: false, **)
          source_file = Metimur.parse_file(path)

          case format
          when "json"
            puts JSON.pretty_generate(source_file.to_h)
          else
            print_text_output(source_file, details)
          end
        rescue Errno::ENOENT
          puts "Error: File not found - #{path}"
          exit(1)
        rescue Metimur::Error => e
          puts "Error: #{e.message}"
          exit(1)
        end

        private

        def print_text_output(source_file, details)
          puts "File: #{source_file.path}"
          puts "Total lines: #{source_file.total_lines}"
          puts "\nClasses (#{source_file.classes.count}):"
          source_file.classes.each do |klass|
            puts "  #{klass.name} (#{klass.start_line}..#{klass.end_line})"
            if details
              klass.methods.each do |method|
                puts "    - #{method.name} (#{method.start_line}..#{method.end_line})"
              end
            end
          end

          puts "\nModules (#{source_file.modules.count}):"
          source_file.modules.each do |mod|
            puts "  #{mod.name} (#{mod.start_line}..#{mod.end_line})"
            if details
              mod.methods.each do |method|
                puts "    - #{method.name} (#{method.start_line}..#{method.end_line})"
              end
            end
          end

          puts "\nTop-level methods (#{source_file.methods.count}):"
          source_file.methods.each do |method|
            puts "  #{method.name} (#{method.start_line}..#{method.end_line})"
          end
        end
      end
    end
  end
end
