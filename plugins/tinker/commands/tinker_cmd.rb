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
        
        saves = %w{Fortitude Reflex Will}
        list = []
        saves.each do |save|
          list << "#{save}: #{combat.save}"
        end
        
        client.emit list
      end

    end
  end
end
