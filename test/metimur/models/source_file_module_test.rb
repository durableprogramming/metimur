# frozen_string_literal: true

require "test_helper"
class SourceFileModuleTest < Minitest::Test
  def setup
    @source_file = setup_source_file(<<~RUBY)
      module TestModule
        class InnerClass
          def test_method
            puts "Hello"
          end
        end
      #{"  "}
        module SubModule
          def sub_method
            puts "World"#{" "}
          end
        end
      #{"  "}
        def module_method
          puts "Direct module method"
        end
      end
    RUBY
    @module = Metimur::Models::SourceFileModule.new(
      name: "TestModule",
      source_file: @source_file,
      start_line: 1,
      end_line: 15
    )
  end

  def teardown
    teardown_source_file
  end

  def test_initialization
    assert_equal "TestModule", @module.name
    assert_equal @source_file, @module.source_file
    assert_empty @module.methods
    assert_empty @module.comments
    assert_empty @module.classes
    assert_empty @module.submodules
    assert_equal 1, @module.start_line
    assert_equal 15, @module.end_line
  end

  def test_add_method
    method = Metimur::Models::SourceFileMethod.new(@source_file, "module_method", 11, 13)
    @module.add_method(method)

    assert_includes @module.methods, method
  end

  def test_add_comment
    comment = "Test comment"
    @module.add_comment(comment)

    assert_includes @module.comments, comment
  end

  def test_add_class
    klass = Metimur::Models::SourceFileClass.new(
      name: "InnerClass",
      source_file: @source_file,
      start_line: 2,
      end_line: 6
    )
    @module.add_class(klass)

    assert_includes @module.classes, klass
  end

  def test_add_submodule
    submodule = Metimur::Models::SourceFileModule.new(
      name: "SubModule",
      source_file: @source_file,
      start_line: 7,
      end_line: 11
    )
    @module.add_submodule(submodule)

    assert_includes @module.submodules, submodule
  end

  def test_metadata
    method = Metimur::Models::SourceFileMethod.new(@source_file, "module_method", 11, 13)
    klass = Metimur::Models::SourceFileClass.new(
      name: "InnerClass",
      source_file: @source_file,
      start_line: 2,
      end_line: 6
    )
    submodule = Metimur::Models::SourceFileModule.new(
      name: "SubModule",
      source_file: @source_file,
      start_line: 7,
      end_line: 11
    )

    @module.add_method(method)
    @module.add_class(klass)
    @module.add_submodule(submodule)
    @module.add_comment("Test comment")

    metadata = @module.metadata

    assert_equal "TestModule", metadata[:name]
    assert_equal 1, metadata[:start_line]
    assert_equal 15, metadata[:end_line]
    assert_equal 1, metadata[:methods_count]
    assert_equal 1, metadata[:comments_count]
    assert_equal 1, metadata[:classes_count]
    assert_equal 1, metadata[:submodules_count]
  end

  def test_to_s
    assert_equal "TestModule (1..15)", @module.to_s
  end

  def test_inspect
    assert_equal "#<Metimur::Models::SourceFileModule TestModule (1..15)>", @module.inspect
  end

  def test_equality
    module1 = Metimur::Models::SourceFileModule.new(
      name: "TestModule",
      source_file: @source_file,
      start_line: 1,
      end_line: 15
    )
    module2 = Metimur::Models::SourceFileModule.new(
      name: "OtherModule",
      source_file: @source_file,
      start_line: 1,
      end_line: 15
    )

    assert_equal @module, module1
    refute_equal @module, module2
  end

  def test_file_path
    assert_equal @source_file.path, @module.file_path
  end

  def test_source_code
    source_code = @module.source_code

    assert_kind_of Array, source_code
    assert_equal 15, source_code.length
  end

  def test_update_location
    @module.update_location(start_line: 2, end_line: 16)

    assert_equal 2, @module.start_line
    assert_equal 16, @module.end_line
  end

  def test_namespace
    mod = Metimur::Models::SourceFileModule.new(
      name: "Outer::TestModule",
      source_file: @source_file,
      start_line: 1,
      end_line: 15
    )

    assert_equal "Outer", mod.namespace
    assert_equal "", @module.namespace
  end

  def test_simple_name
    mod = Metimur::Models::SourceFileModule.new(
      name: "Outer::TestModule",
      source_file: @source_file,
      start_line: 1,
      end_line: 15
    )

    assert_equal "TestModule", mod.simple_name
    assert_equal "TestModule", @module.simple_name
  end

  def test_full_name
    mod = Metimur::Models::SourceFileModule.new(
      name: "Outer::TestModule",
      source_file: @source_file,
      start_line: 1,
      end_line: 15
    )

    assert_equal "Outer::TestModule", mod.full_name
    assert_equal "TestModule", @module.full_name
  end
end
