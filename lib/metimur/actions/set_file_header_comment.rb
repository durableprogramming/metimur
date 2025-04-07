module Metimur
  module Actions
    class SetFileHeaderComment
      def initialize(file_path, comment_lines)
        @file_path = file_path
        @comment_lines = Array(comment_lines)
        @source_file = Models::SourceFile.new(file_path)
      end

      def call
        lines = File.readlines(@file_path)
        remove_existing_header_comments(lines)
        insert_new_header_comments(lines)
        write_file(lines)
      end

      private

      def remove_existing_header_comments(lines)
        while !lines.empty? && comment_line?(lines.first)
          lines.shift
        end
      end

      def insert_new_header_comments(lines)
        formatted_comments = @comment_lines.map { |line| "# #{line}\n" }
        formatted_comments << "\n" unless formatted_comments.empty?
        lines.unshift(*formatted_comments)
      end

      def comment_line?(line)
        line.strip.start_with?('#')
      end

      def write_file(lines)
        File.write(@file_path, lines.join)
      end
    end
  end
end
