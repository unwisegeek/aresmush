module AresMUSH
  module Tinker
    class TinkerCmd
      include CommandHandler
      
      def check_can_manage
        return t('dispatcher.not_allowed') if !enactor.has_permission?("tinker")
        return nil
      end
      
      def handle
        char=Character.find_one_by_name("Testchar")
        
        result = ClassTargetFinder.find("Wisdom",Pf2eAbilities,char)
        if result.found?
            client.emit "#{result.target.name}"
            client.emit "#{result.target.base_val}"   
            client.emit "#{result.target.character.name}"
        else 
            client.emit "#{result.error}"
        end
        
        client.emit "#{char.combat.key_abil}"
        
      end

    end
  end
end
