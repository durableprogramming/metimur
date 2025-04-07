require "test_helper"
require_relative '../../../lib/metimur/actions/set_yard_comment'

class SetYardCommentTest < Minitest::Test
  def setup
    @source_file = setup_source_file(<<~RUBY)
      class TestClass
        # Old comment
        def test_method
          puts "Hello"
        end
      end
    RUBY
  end

  def teardown
    teardown_source_file
  end

  def test_set_yard_comment_replaces_existing_comment
    action = Metimur::Actions::SetYardComment.new
    new_comment = ["@param name [String] The name parameter", "@return [void]"]
    
    result = action.call(@source_file.source_lines.join, 3, new_comment)
    
    expected = <<~RUBY.chomp
      class TestClass
        # @param name [String] The name parameter
        # @return [void]
        def test_method
          puts "Hello"
        end
      end
    RUBY
    
    assert_equal expected, result.join("\n")
  end

  def test_set_yard_comment_preserves_indentation
    @source_file = setup_source_file(<<~RUBY)
      class TestClass
          # Old comment
          def test_method
            puts "Hello"
          end
      end
    RUBY

    action = Metimur::Actions::SetYardComment.new
    new_comment = ["@param name [String] The name parameter"]
    
    result = action.call(@source_file.source_lines.join, 3, new_comment)
    
    assert_match(/^    # @param/, result[1])
  end

  def test_set_yard_comment_with_no_existing_comment
    @source_file = setup_source_file(<<~RUBY)
      class TestClass
        def test_method
          puts "Hello"
        end
      end
    RUBY

    action = Metimur::Actions::SetYardComment.new
    new_comment = ["@param name [String] The name parameter"]
    
    result = action.call(@source_file.source_lines.join, 2, new_comment)
    
    assert_match(/# @param/, result[1])
  end

  def test_set_yard_comment_with_multiple_existing_comments
    @source_file = setup_source_file(<<~RUBY)
      class TestClass
        # First comment
        # Second comment
        # Third comment
        def test_method
          puts "Hello"
        end
      end
    RUBY

    action = Metimur::Actions::SetYardComment.new
    new_comment = ["@param name [String] The name parameter"]
    
    result = action.call(@source_file.source_lines.join, 5, new_comment)
    
    refute_match(/First comment/, result.join("\n"))
    refute_match(/Second comment/, result.join("\n"))
    refute_match(/Third comment/, result.join("\n"))
    assert_match(/# @param/, result.join("\n"))
  end

  def test_set_yard_comment_with_empty_comment
    action = Metimur::Actions::SetYardComment.new
    new_comment = []
    
    result = action.call(@source_file.source_lines.join, 3, new_comment)
    
    refute_match(/# Old comment/, result.join("\n"))
    assert_match(/def test_method/, result.join("\n"))
  end
end
