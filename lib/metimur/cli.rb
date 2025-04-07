require "dry/cli"
require "dry/inflector"
require "pathname"

module Metimur
  module CLI
    module Commands
      extend Dry::CLI::Registry

      inflector = Dry::Inflector.new
      commands_path = Pathname.new(__dir__).join("cli/commands")
      
      Dir[commands_path.join("*.rb")].each do |file|
        require file
        
        basename = File.basename(file, ".rb")
        class_name = inflector.classify(basename)
        command_name = inflector.underscore(basename)
        
        command_class = Commands.const_get(class_name)
        register command_name, command_class
      end
    end
  end
end
