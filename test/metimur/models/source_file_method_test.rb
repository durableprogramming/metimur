# frozen_string_literal: true

require "test_helper"

class SourceFileMethodTest < Minitest::Test
  def setup
    @source_file = setup_source_file(<<~RUBY)
      class TestClass
        def test_method(param1, param2)
          # Test comment
          puts "Hello"
        end
      end
    RUBY
    @method = Metimur::Models::SourceFileMethod.new(@source_file, "test_method", 2, 5)
  end

  def teardown
    teardown_source_file
  end

  def test_initialization
    assert_equal "test_method", @method.name
    assert_equal 2, @method.start_line
    assert_equal 5, @method.end_line
    assert_equal :public, @method.visibility
    assert_empty @method.comments
    assert_empty @method.parameters
  end

  def test_add_comment
    comment = "Test comment"
    @method.add_comment(comment)

    assert_includes @method.comments, comment
  end

  def test_add_parameter
    param = "test_param"
    @method.add_parameter(param)

    assert_includes @method.parameters, param
  end

  def test_documented_predicate
    refute_predicate @method, :documented?
    @method.add_comment("Test documentation")

    assert_predicate @method, :documented?
  end

  def test_line_count
    assert_equal 4, @method.line_count
  end

  def test_to_h
    @method.add_comment("Test comment")
    @method.add_parameter("param1")

    hash = @method.to_h

    assert_equal "test_method", hash[:name]
    assert_equal 2, hash[:start_line]
    assert_equal 5, hash[:end_line]
    assert_equal :public, hash[:visibility]
    assert_equal ["Test comment"], hash[:comments]
    assert_equal ["param1"], hash[:parameters]
    assert hash[:documented]
    assert_equal 4, hash[:line_count]
  end

  def test_equality
    method1 = Metimur::Models::SourceFileMethod.new(@source_file, "test_method", 2, 5)
    method2 = Metimur::Models::SourceFileMethod.new(@source_file, "test_method", 2, 5)
    method3 = Metimur::Models::SourceFileMethod.new(@source_file, "other_method", 2, 5)

    assert_equal method1, method2
    refute_equal method1, method3
  end

  def test_method_without_lines
    method = Metimur::Models::SourceFileMethod.new(@source_file, "test_method")

    assert_nil method.source
    assert_equal 0, method.line_count
  end

  def test_visibility_change
    @method.visibility = :private

    assert_equal :private, @method.visibility
  end
end
