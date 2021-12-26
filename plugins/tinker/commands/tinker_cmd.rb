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
        save = "fortitude"
        
        prof_bonus = Pf2e.get_prof_bonus(char, Pf2eCombat.get_save_from_char(char, save))
        
        client.emit "Save: #{save} Prof_bonus: #{prof_bonus}" if prof_bonus
        client.emit "Prof_bonus is nil" if !prof_bonus
        
      end

    end
  end
end
