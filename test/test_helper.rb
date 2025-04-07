# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

require "minitest/autorun"
require "parser/current"
require "metimur"

module TestHelper
  def setup_source_file(content, filename = "test.rb")
    path = File.join(Dir.tmpdir, filename)
    File.write(path, content)
    Metimur::Models::SourceFile.new(path)
  end

  def teardown_source_file(filename = "test.rb")
    path = File.join(Dir.tmpdir, filename)
    FileUtils.rm_f(path)
  end

  def parse_source(content)
    source_file = setup_source_file(content)
    parser = Metimur::ParseSourceCode.new(source_file)
    parser.parse
    source_file
  end

  def assert_class_exists(source_file, class_name)
    assert source_file.classes.any? { |klass| klass.name == class_name },
           "Expected to find class #{class_name}"
  end

  def assert_method_exists(source_file, method_name)
    assert source_file.methods.any? { |method| method.name == method_name },
           "Expected to find method #{method_name}"
  end

  def assert_module_exists(source_file, module_name)
    assert source_file.modules.any? { |mod| mod.name == module_name },
           "Expected to find module #{module_name}"
  end
end

module Minitest
  class Test
    include TestHelper
  end
end
