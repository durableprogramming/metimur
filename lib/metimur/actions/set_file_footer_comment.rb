module Metimur
  module Actions
    class SetFileFooterComment
      def initialize(file_path, comment_lines)
        @file_path = file_path
        @comment_lines = Array(comment_lines)
        @source_file = Models::SourceFile.new(file_path)
      end

      def call
        lines = File.readlines(@file_path)
        remove_existing_footer_comments(lines)
        append_new_footer_comments(lines)
        write_file(lines)
      end

      private

      def remove_existing_footer_comments(lines)
        while !lines.empty? && comment_line?(lines.last)
          lines.pop
        end
      end

      def append_new_footer_comments(lines)
        lines << "\n" unless lines.empty? || lines.last.strip.empty?
        @comment_lines.each do |line|
          lines << "# #{line}\n"
        end
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
