module Bpl
  module Analysis
    class Writing < Bpl::Pass

      flag "-o", "--output [FILENAME]" do |f|
        option :file, f
      end

      def first?
        res = @first.nil?
        @first = false
        res
      end

      def run! program
        first = first?
        if file
          File.open(file, first ? 'w' : 'a') do |f|
            f.puts "---".comment unless first
            f.puts program
          end
        elsif $stdout.tty?
          puts "---"
          puts program.hilite
        else
          puts "---".comment
          puts program
        end
        false
      end

    end
  end
end