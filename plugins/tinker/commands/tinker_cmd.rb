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
        
        combat = char.combat
        save_list = combat.saves
        
        if save_list
            save_list.each_pair do |k,v|
                client.emit "#{key} - #{value}"
            end
        else 
            client.emit "No save list."
        end
        
      end

    end
  end
end
