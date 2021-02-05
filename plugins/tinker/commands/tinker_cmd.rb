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
        
        section = Global.read_config('pf2e_' + selected_element)
        
        section
            
      end

    end
  end
end
