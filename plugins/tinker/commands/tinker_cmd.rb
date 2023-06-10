module AresMUSH
  module Tinker
    class TinkerCmd
      include CommandHandler
      
      def check_can_manage
        return t('dispatcher.not_allowed') if !enactor.has_permission?("tinker")
        return nil
      end
      
      def handle
        
        category = "weapons"
      
        list_key = "pf2e_" + category
        
        list = Global.read_config(list_key)
        
        client.emit list
        
      end

    end
  end
end
