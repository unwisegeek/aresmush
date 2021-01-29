module AresMUSH
  module Tinker
    class TinkerCmd
      include CommandHandler
      
      def check_can_manage
        return t('dispatcher.not_allowed') if !enactor.has_permission?("tinker")
        return nil
      end
      
      def handle
        char = Character.find_one_by_name("Landtest")
        
        client.emit char.pf2sheet
        client.emit char.pf2sheet.abilities

      end

    end
  end
end
