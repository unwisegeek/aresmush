module AresMUSH
  module Tinker
    class TinkerCmd
      include CommandHandler
      
      def check_can_manage
        return t('dispatcher.not_allowed') if !enactor.has_permission?("tinker")
        return nil
      end
      
      def handle
      
          charclass = "Alchemist"
          align = "NG"
          deity = nil
            
          class_alignments = Global.read_config('pf2e_class', charclass, 'allowed_alignments')
          requires_deity = Global.read_config('pf2e_class', charclass, 'check_deity')
          deity_alignments = Global.read_config('pf2e_deities', deity, 'allowed_alignments')
    
          if !class_alignments
            class_alignments = Global.read_config('pf2e', 'allowed_alignments')
          end
    
          if requires_deity && (!deity || deity.blank?)
            error = t('pf2e.class_requires_deity')
          elsif requires_deity
            error = class_alignments & deity_alignments.include?(align) ? nil : t('pf2e.class_deity_mismatch')
          else
            error = class_alignments.include?(align) ? nil : t('pf2e.class_mismatch')
          end
    
          client.emit class_alignments
          client.emit error ? error : "None"
      end

    end
  end
end
