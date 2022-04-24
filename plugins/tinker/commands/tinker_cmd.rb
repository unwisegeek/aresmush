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
        armor = Pf2eCombat.get_equipped_armor(char)
        
        client.emit "Armor is nil" if armor == nil
        
        if armor 
            client.emit armor.name
        else 
            client.emit "No armor found."
        end
        
        
      end

    end
  end
end
