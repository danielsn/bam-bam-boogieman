module Bpl
  module Analysis
    def self.desugar! program
      program.each do |stmt|
        case stmt
        when IfStatement
          block = stmt.block
          body = block.body
          idx = block.index(stmt)
          new_blocks = []

          ## TODO REsTRuCTURE, AND USE UNIQUE NAMES

          then_block = stmt.blocks.first
          then_block.unshift bpl("assume #{stmt.condition};", scope: stmt)
          then_block.labels << Label.new(name: "$IF") if then_block.labels.empty?
          stmt.blocks.last << bpl("goto $CONTINUE;")
          new_blocks += stmt.blocks

          case stmt.else
          when IfStatement
          when Enumerable
          else
            new_blocks << bpl(<<-END)
            $ELSE:
              assume !#{stmt.condition};
              goto $CONTINUE;
            END
          end

          new_blocks << continue_block = bpl("$CONTINUE: ")

          stmt.replace_with bpl("goto $IF, $ELSE;", scope: stmt)
          block[idx+1..-1].each do |stmt|
            continue_block << stmt
            block.delete(stmt)
          end
          
          block.insert_after *new_blocks

        when WhileStatement
          head = bpl("$HEAD: ")
          body = bpl("$BODY: ")
          exit = bpl("$EXIT: ")
          
          ## TODO finish this
        end
      end
    end
  end
end