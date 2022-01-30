module AresMUSH
  module Tinker
    class TinkerCmd
      include CommandHandler
      
      def check_can_manage
        return t('dispatcher.not_allowed') if !enactor.has_permission?("tinker")
        return nil
      end
      
      def handle
        char = Character.find_one_by_name("testchar")
        
        abilities = char.abilities
        
        ability = "Dexterity"
        
        object = abilities.select { |a| a.name_upcase == ability.upcase }
          
        client.emit ability
        client.emit object.count

      end

    end
  end
end
