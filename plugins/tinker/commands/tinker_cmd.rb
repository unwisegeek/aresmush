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
        
        int_mod = 3
        
        ary = []
        
        int_skills = [].fill("open", nil, int_mod)
        
        client.emit int_skills
        
      end

    end
  end
end
