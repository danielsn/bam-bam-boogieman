module Bpl
  @@foo=false
  class CostModeling < Pass
    EXEMPTION_LIST = [
      '\$alloc',
      '\$free',
      'boogie_si_',
      '__VERIFIER_',
      '__SIDEWINDER_',
      '__SMACK_(?!static_init)',
      'llvm.dbg'
    ]

    EXEMPTIONS = /#{EXEMPTION_LIST * "|"}/

    LEAKAGE_ANNOTATION_NAME =  "__VERIFIER_ASSUME_LEAKAGE"

    def exempt? decl
      EXEMPTIONS.match(decl) && true
    end

    depends :normalization
    depends :ct_annotation, :cfg_construction
    depends :resolution, :loop_identification
    depends :definition_localization, :liveness
    invalidates :all
    switch "--cost-modeling", "Add cost-tracking variables."


    def is_leakage_annotation_stmt? stmt
      return false unless stmt.is_a?(CallStatement)
      return stmt.procedure.to_s == LEAKAGE_ANNOTATION_NAME
    end

    #
    def has_leakage_annotation? decl
      return false unless decl.body
      return (not (decl.body.select{|r| is_leakage_annotation_stmt? r }.empty?))
    end


    #the annotation should have one argument, and we just want whatever it is
    def get_annotation_value annotationStmt
      raise "not an annotation stmt" unless is_leakage_annotation_stmt? annotationStmt
      raise "annotation should have one argument" unless annotationStmt.arguments.length == 1
      return annotationStmt.arguments[0].to_s
    end
    
    def annotate_function_body! decl
      if (has_leakage_annotation? decl) then
        decl.body.select{ |s| is_leakage_annotation_stmt? s }.each do |s| 
          value = get_annotation_value s
          s.insert_after(bpl("$l := $l + #{value};"))
        end
      else
        decl.body.select{ |s| s.is_a?(AssumeStatement)}.each do |stmt|
          next unless values = stmt.get_attribute(:'smack.InstTimingCost.Int64')
          stmt.insert_after(bpl("$l := $add.i32($l, #{values.first});"))
        end
      end
    end
 
    def run! program
      @@foo = true
      # add cost global variable
      program.prepend_children(:declarations, bpl("var $l: int;"))

      # update cost global variable
      program.each_child do |decl|
        next unless decl.is_a?(ProcedureDeclaration)
        next if exempt?(decl.name)
        next unless decl.body
        annotate_function_body! decl
      end

    end
  end
end