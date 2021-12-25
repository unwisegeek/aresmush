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
        
        score = Pf2eAbilities.get_score(char,"Wisdom")
        
        mod = Pf2eAbiliies.abilmod(score)
        
        client.emit "Score: #{score}"
        client.emit "Mod: @{mod}"
      end

    end
  end
end
