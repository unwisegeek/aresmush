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
          
        skill_list = Global.read_config('pf2e_skills').keys + [ "open" ]
        
        index = skill_list.index("open")
        
        client.emit index 
        client.emit skill_list.join(" | ")
      end

    end
  end
end
