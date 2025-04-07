# frozen_string_literal: true

require "test_helper"

class SourceFileClassTest < Minitest::Test
  def setup
    @source_file = setup_source_file(<<~RUBY)
      class TestClass
        def test_method
          puts "Hello"
        end
      #{"  "}
        # Test comment
        def another_method
          puts "World"
        end
      end
    RUBY
    @class = Metimur::Models::SourceFileClass.new(
      name: "TestClass",
      source_file: @source_file,
      start_line: 1,
      end_line: 9
    )
  end

  def teardown
    teardown_source_file
  end

  def test_initialization
    assert_equal "TestClass", @class.name
    assert_equal @source_file, @class.source_file
    assert_empty @class.methods
    assert_empty @class.comments
    assert_equal 1, @class.start_line
    assert_equal 9, @class.end_line
  end

  def test_add_method
    method = Metimur::Models::SourceFileMethod.new(@source_file, "test_method", 2, 4)
    @class.add_method(method)

    assert_includes @class.methods, method
  end

  def test_add_comment
    comment = "Test comment"
    @class.add_comment(comment)

    assert_includes @class.comments, comment
  end

  def test_metadata
    method = Metimur::Models::SourceFileMethod.new(@source_file, "test_method", 2, 4)
    @class.add_method(method)
    @class.add_comment("Test comment")

    metadata = @class.metadata

    assert_equal "TestClass", metadata[:name]
    assert_equal 1, metadata[:start_line]
    assert_equal 9, metadata[:end_line]
    assert_equal 1, metadata[:methods_count]
    assert_equal 1, metadata[:comments_count]
  end

  def test_to_s
    assert_equal "TestClass (1..9)", @class.to_s
  end

  def test_inspect
    assert_equal "#<Metimur::Models::SourceFileClass TestClass (1..9)>", @class.inspect
  end

  def test_equality
    class1 = Metimur::Models::SourceFileClass.new(
      name: "TestClass",
      source_file: @source_file,
      start_line: 1,
      end_line: 9
    )
    class2 = Metimur::Models::SourceFileClass.new(
      name: "OtherClass",
      source_file: @source_file,
      start_line: 1,
      end_line: 9
    )

    assert_equal @class, class1
    refute_equal @class, class2
  end

  def test_file_path
    assert_equal @source_file.path, @class.file_path
  end

  def test_source_code
    source_code = @class.source_code

    assert_kind_of Array, source_code
    assert_equal 9, source_code.length
  end

  def test_update_location
    @class.update_location(start_line: 2, end_line: 10)

    assert_equal 2, @class.start_line
    assert_equal 10, @class.end_line
  end

  def test_namespace
    klass = Metimur::Models::SourceFileClass.new(
      name: "Module::TestClass",
      source_file: @source_file,
      start_line: 1,
      end_line: 9
    )

    assert_equal "Module", klass.namespace
    assert_equal "", @class.namespace
  end

  def test_simple_name
    klass = Metimur::Models::SourceFileClass.new(
      name: "Module::TestClass",
      source_file: @source_file,
      start_line: 1,
      end_line: 9
    )

    assert_equal "TestClass", klass.simple_name
    assert_equal "TestClass", @class.simple_name
  end
end
