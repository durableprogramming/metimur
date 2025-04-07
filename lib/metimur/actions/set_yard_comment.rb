
module Metimur
  module Actions
    class SetYardComment
      attr_accessor :file_path, :comment_lines
      def initialize()
        @file_path = file_path
        line_number = line_number
        @line_prefix = 'XXXX'
      end

      def call(source, line_number, new_comment)
        @line_number = line_number
        @lines = source.split("\n")
        remove_existing_comments()
        insert_new_comments(new_comment) 
        @lines
      end

      private

      def remove_existing_comments()
        current_line = @line_number - 1
        @line_prefix = begin
          line = @lines[current_line]
          line =~ /^([ \t]+)/
          $1
        end || ''
        while current_line > 0 && yard_comment?(@lines[current_line - 1])
          line = @lines.delete_at(current_line - 1)

          @line_number -= 1
          current_line -= 1
        end
      end

      def insert_new_comments( new_comment)
        formatted_comments = [new_comment].flatten.map{|_| _.split("\n")}.flatten.map { |line| @line_prefix + "# #{line.strip}" }
        @lines.insert(@line_number - 1, *formatted_comments)
      end

      def yard_comment?(line)
        line && line.strip.start_with?('#')
      end
    end
  end
end
