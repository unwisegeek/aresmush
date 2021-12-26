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
        
        prof = Pf2eCombat.get_save_from_char(char, "fortitude")
        
        client.emit "Prof is nil" if !prof
        client.emit "#{prof[0].upcase}" if prof
        
      end

    end
  end
end
