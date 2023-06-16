module AresMUSH
  module Tinker
    class TinkerCmd
      include CommandHandler
      
      def check_can_manage
        return t('dispatcher.not_allowed') if !enactor.has_permission?("tinker")
        return nil
      end
      
      def handle
        string = "(%xc1%xn)"
        
        new_string = string.delete_prefix("(%xc").delete_suffix("%xn)")
        
        client.emit string
        client.emit new_string
        
      end

    end
  end
end
