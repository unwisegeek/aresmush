module AresMUSH
  module Tinker
    class TinkerCmd
      include CommandHandler
      
      def check_can_manage
        return t('dispatcher.not_allowed') if !enactor.has_permission?("tinker")
        return nil
      end
      
      def handle
        
        selected_element = "ancestry"
        
        case selected_element
        when "ancestry" 
            client.emit "I Got this."
        when !ancestry
            client.emit "Wrong!"
        end
            
      end

    end
  end
end
