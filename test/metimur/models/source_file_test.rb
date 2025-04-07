# frozen_string_literal: true

require "test_helper"

class SourceFileTest < Minitest::Test
  def setup
    @test_file_content = <<~RUBY
      class TestClass
        def test_method
          puts "Hello"
        end
      end

      module TestModule
        def module_method
          puts "World"
        end
      end
    RUBY
    @source_file = setup_source_file(@test_file_content)
    @parser = Metimur::ParseSourceCode.new(@source_file)
    @parsed_file = @parser.parse
  end

  def teardown
    teardown_source_file
  end

  def test_parse_basic
    assert_equal File.expand_path("test.rb", Dir.tmpdir), @source_file.path
    assert_equal 1, @source_file.classes.length
    assert_equal 2, @source_file.methods.length
    assert_equal 1, @source_file.modules.length
    assert_equal @test_file_content.lines.count, @source_file.total_lines
  end

  def test_add_class
    klass = Metimur::Models::SourceFileClass.new(
      name: "TestClass",
      source_file: @source_file,
      start_line: 1,
      end_line: 5
    )
    @source_file.add_class(klass)

    assert_equal 2, @source_file.classes.size
    assert_equal klass, @source_file.classes.first
  end

  def test_add_method
    method = Metimur::Models::SourceFileMethod.new(@source_file, "test_method", 2, 4)
    @source_file.add_method(method)

    assert_equal 3, @source_file.methods.size
    assert_equal method, @source_file.methods.first
  end

  def test_add_module
    mod = Metimur::Models::SourceFileModule.new(
      name: "TestModule",
      source_file: @source_file,
      start_line: 7,
      end_line: 11
    )
    @source_file.add_module(mod)

    assert_equal 2, @source_file.modules.size
    assert_equal mod, @source_file.modules.first
  end

  def test_find_class
    klass = Metimur::Models::SourceFileClass.new(
      name: "TestClass",
      source_file: @source_file,
      start_line: 1,
      end_line: 5
    )
    @source_file.add_class(klass)

    assert_equal klass, @source_file.find_class("TestClass")
    assert_nil @source_file.find_class("NonExistentClass")
  end

  def test_find_method
    method = Metimur::Models::SourceFileMethod.new(@source_file, "test_method", 2, 4)
    @source_file.add_method(method)

    assert_equal method, @source_file.find_method("test_method")
    assert_nil @source_file.find_method("non_existent_method")
  end

  def test_find_module
    mod = Metimur::Models::SourceFileModule.new(
      name: "TestModule",
      source_file: @source_file,
      start_line: 7,
      end_line: 11
    )
    @source_file.add_module(mod)

    assert_equal mod, @source_file.find_module("TestModule")
    assert_nil @source_file.find_module("NonExistentModule")
  end

  def test_to_h
    klass = Metimur::Models::SourceFileClass.new(
      name: "TestClass",
      source_file: @source_file,
      start_line: 1,
      end_line: 5
    )
    @source_file.add_class(klass)
    hash = @source_file.to_h

    assert_kind_of Hash, hash
    assert_equal @source_file.path, hash[:path]
    assert_equal 2, hash[:classes].size
    assert_equal @source_file.total_lines, hash[:total_lines]
  end

  def test_equality
    file1 = setup_source_file("class A; end", "test1.rb")
    file2 = setup_source_file("class B; end", "test1.rb")
    file3 = setup_source_file("class C; end", "test2.rb")

    assert_equal file1, file2
    refute_equal file1, file3

    teardown_source_file("test1.rb")
    teardown_source_file("test2.rb")
  end
end
