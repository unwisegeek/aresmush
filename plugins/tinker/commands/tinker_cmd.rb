module AresMUSH
  module Tinker
    class TinkerCmd
      include CommandHandler
      
      def check_can_manage
        return t('dispatcher.not_allowed') if !enactor.has_permission?("tinker")
        return nil
      end
      
      def handle
      
        char = Character.find_one_by_name("Testchar") 
      
        feats = Global.read_config('pf2e_feats')
        
        list = []
        
        feats.each do |f,d|
            can_take = Pf2e.can_take_feat?(char, f)
            is_charclass = d['feat_type'].include? 'Charclass' 
            
            list << f if can_take && is_charclass
        end
        
        client.emit list
        
      end

    end
  end
end
