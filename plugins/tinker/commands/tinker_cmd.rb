module AresMUSH
  module Tinker
    class TinkerCmd
      include CommandHandler
      
      def check_can_manage
        return t('dispatcher.not_allowed') if !enactor.has_permission?("tinker")
        return nil
      end
      
      def handle
        char = AresMUSH::Character.find_one_by_name('Landtest')
        
        base_info = char.pf2_base_info
        faith = char.pf2_faith
        
        charclass = base_info['charclass']
        subclass = base_info['specialize']
        deity = faith['deity']
        align = faith['alignment']
        
        client.emit "Charclass = " + charclass
        client.emit "Subclass = " + subclass 
        client.emit "Deity = " + deity  
        client.emit "Alignment = " + align
      
        all_align = Global.read_config('pf2e','allowed_alignments')
        subclass_align = Global.read_config('pf2e_specialty', subclass, 'allowed_alignments')
        class_align = Global.read_config('pf2e_class', charclass, 'allowed_alignments')
        requires_deity = Global.read_config('pf2e_class', charclass, 'use_deity')
        deity_alignments = Global.read_config('pf2e_deities', deity, 'allowed_alignments')

        calign = class_align ? class_align : all_align
        salign = subclass_align ? subclass_align : all_align

        alignments = calign & salign
        
        client.emit alignments
        client.emit deity_alignments
        

        if requires_deity && (!deity || deity.blank?)
            error = t('pf2e.class_requires_deity')
        elsif requires_deity
            dalign = alignments & deity_alignments
            
            client.emit dalign
            
            error = dalign.include?(align) ?
                    nil :
                    t('pf2e.class_deity_mismatch')
        else
            error = alignments.include?(align) ? nil : t('pf2e.class_mismatch')
        end
        
        client.emit error
        
      end

    end
  end
end
