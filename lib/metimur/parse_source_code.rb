# frozen_string_literal: true

require_relative "models/source_file"
require_relative "models/source_file_module"
require_relative "models/source_file_class"
require_relative "models/source_file_method"

module Metimur
  class ParseSourceCode
    def initialize(source_file)
      @source_file = source_file
      @current_class = nil
      @current_module = nil
      @current_method = nil
    end

    def parse
      parse_file
      @source_file
    end

    private

    def parse_file
      require "parser/current"
      buffer = Parser::Source::Buffer.new(@source_file.path)
      buffer.source = File.read(@source_file.path)
      parser = Parser::CurrentRuby.new
      ast = parser.parse(buffer)
     path = []
      process_node(ast)
    rescue Parser::SyntaxError => e
      raise Error, "Syntax error in #{@source_file.path}: #{e.message}"
    end

    def process_node(node, parent_node: nil, path:[])
      return unless node.is_a?(Parser::AST::Node)

      case node.type
      when :class
        process_class_node(node, path: path, parent_node: parent_node)
      when :module
        process_module_node(node, path: path, parent_node: parent_node)
      when :defs, :def
        process_method_node(node, path: path, parent_node: parent_node)
      else
        node.children.each { |child| process_node(child, path: path, parent_node: parent_node) }
      end

    end

    def process_class_node(node, path:[], parent_node: nil)
      name = extract_constant_name(node.children[0])
      start_line = node.location.line
      end_line = node.location.last_line

      klass = Metimur::Models::SourceFileClass.new(
        name: name,
        source_file: @source_file,
        start_line: start_line,
        end_line: end_line
      )
      if parent_node
        klass.parent_node = parent_node
      end
      klass.path = path

      if @current_module
        @current_module.add_class(klass)
      else
        @source_file.add_class(klass)
      end

      new_path = path + [name]
      node.children.each { |child| 
        process_node(child, path: new_path, parent_node: klass) 
      }

    end

    def process_module_node(node, path:[], parent_node: nil)
      name = extract_constant_name(node.children[0])
      start_line = node.location.line
      end_line = node.location.last_line

      mod = Models::SourceFileModule.new(
        name: name,
        source_file: @source_file,
        start_line: start_line,
        end_line: end_line
      )
      if parent_node
        klass.parent_node = parent_node
      end

      if @current_module
        @current_module.add_submodule(mod)
      else
        @source_file.add_module(mod)
      end

      new_path = path + [name]

      node.children.each { |child| process_node(child, path: new_path, parent_node: mod) }

    end

    def process_method_node(node, path:[], parent_node:nil)

      name = node.children[0].to_s

      if name == '(self)'
        name = 'self.' + node.children[1].to_s
      end

      start_line = node.location.line
      end_line = node.location.last_line

      method = Metimur::Models::SourceFileMethod.new(@source_file, name, start_line, end_line)
      method.path = path
      method.parent_node = parent_node

      if parent_node
        method.parent_node = parent_node
      end


      process_method_parameters(node, method)

      if @current_class
        @current_class.add_method(method)
      elsif @current_module
        @current_module.add_method(method)
      else
        @source_file.add_method(method)
      end
    end

    def process_method_parameters(node, method)
      args = node.children[1]
      return unless args.is_a?(Parser::AST::Node)

      args.children.each do |arg|
        next unless arg.is_a?(Parser::AST::Node)

        method.add_parameter(arg.children[0].to_s)
      end
    end

    def extract_constant_name(node)
      return node.children[1].to_s if node.type == :const && node.children[0].nil?

      left = extract_constant_name(node.children[0]) if node.children[0]
      right = node.children[1].to_s

      [left, right].compact.join("::")
    end
  end
end
