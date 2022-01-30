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
        
        ability = "Dexterity"
        
        object = ClassTargetFinder.find(ability,Pf2eAbilities,char)
        
          if object.found?
            ability = object.target
            base = object.target.base_val
          else
            return nil
          end
          
          client.emit ability
          client.emit base
            
      end

    end
  end
end
