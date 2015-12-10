module Bpl

  module Transformation
    class Splitting < Bpl::Pass

      depends :entrypoint_localization
      flag "--splitting", "Split annotated procedures into sepearate programs."

      def split?(decl)
        decl.is_a?(ProcedureDeclaration) &&
        ( decl.specifications.any?{|s| s.is_a?(EnsuresClause)} ||
          entrypoint_localization.entrypoints.include?(decl) )
      end

      def run! program
        splits = []
        program.declarations.select(&method(:split?)).each_with_index do |p,i|
          split = Program.new(declarations: [])
          program.declarations.each do |decl|
            d = decl.copy
            if split?(decl)
              d.remove_attribute(:entrypoint)
              if d.name == p.name
                d.add_attribute(:entrypoint)
              else
                d.body.remove
              end
            end
            split.append_children(:declarations, d)
          end
          splits << split
        end
        splits
      end
    end
  end

end
