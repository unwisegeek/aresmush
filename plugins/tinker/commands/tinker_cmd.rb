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
      
        feat = "sdfsdg"
      
        can_take = Pf2e.can_take_feat?(char,feat) ? "Yes" : "No"
        
        client.emit can_take
        
      end

    end
  end
end
