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

        strength = Pf2e.find_character_ability(char, 'ability', "Strength")
        
        client.emit "Strength: #{strength.name}"
      end

    end
  end
end
