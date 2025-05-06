# frozen_string_literal: true

# CLI module for Metimur providing command-line interface capabilities.
# This file defines the main CLI registry structure using dry-cli
# and automatically loads all commands from the commands directory.
# The registry uses dynamic class loading and naming conventions to
# build the command structure from files in the cli/commands directory.

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

# Copyright (c) 2025 Durable Programming, LLC. All rights reserved.
