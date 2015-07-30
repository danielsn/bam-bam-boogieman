module Bpl
  module Transformation
    class Simplification < Bpl::Pass

      def self.description
        <<-eos
          Various code simplifications.
          * remove trivial assume (true) statements
        eos
      end

      depends :modifies_correction

      def run! program
        program.each do |elem|
          case elem
          when ProcedureDeclaration
            if elem.modifies.empty? && elem.returns.empty? && elem.body
              info "SIMPLIFYING TRIVIAL PROCEDURE"
              info elem.to_s.indent
              info
              elem.replace_children(:body,nil)
            end

          when AssumeStatement, AssertStatement
            expr = elem.expression
            if expr.is_a?(BooleanLiteral) && expr.value == true
              info "REMOVING TRIVIAL STATEMENT"
              info elem.to_s.indent
              info
              elem.remove
            end
          end
        end
      end
    end
  end
end
