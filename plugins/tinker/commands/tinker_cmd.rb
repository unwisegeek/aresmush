module AresMUSH
  module Tinker
    class TinkerCmd
      include CommandHandler
      
      def check_can_manage
        return t('dispatcher.not_allowed') if !enactor.has_permission?("tinker")
        return nil
      end
      
      def handle
        feats = Global.read_config('pf2e_feats').keys
    
        feats.each do |name|
            feat_type = Pf2e.get_feat_details(name)['feat_type']
            client.emit "#{name} #{feat_type}"
        end
        
        
        
        
      end

    end
  end
end
