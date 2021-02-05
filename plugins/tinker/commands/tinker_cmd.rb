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
        
        file = 'pf2e_' + "#{selected_element}"
        section = Global.read_config(file)
        options = section.keys.sort
        
        client.emit file
        client.emit section
        client.emit options
            
      end

    end
  end
end
