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
        
        name = "Arcana"
        
        linked_attr = Pf2eSkills.get_linked_attr(name)
        
        abonus = Pf2eAbilities.abilmod(
            Pf2eAbilities.get_score(char, linked_attr)
        )
        
        client.emit linked_attr
        
        client.emit abonus

      end

    end
  end
end
