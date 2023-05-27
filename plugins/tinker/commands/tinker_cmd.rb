module AresMUSH
  module Tinker
    class TinkerCmd
      include CommandHandler
      
      def check_can_manage
        return t('dispatcher.not_allowed') if !enactor.has_permission?("tinker")
        return nil
      end
      
      def handle
        feat_info = Global.read_config('pf2e_feats')
        
        client.emit feat_info['Adopted Ancestry']
        
        
      end

    end
  end
end
