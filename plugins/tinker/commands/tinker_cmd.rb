module AresMUSH
  module Tinker
    class TinkerCmd
      include CommandHandler
      
      def check_can_manage
        return t('dispatcher.not_allowed') if !enactor.has_permission?("tinker")
        return nil
      end
      
      def handle
        Character.all.each do |char|
            hp = char.hp
            
            next if !hp 
            
            hp.temp_max = nil if hp.temp_max
            hp.temp_current = nil if hp.temp_current
            hp.temp_hp = 0
            
            hp.save
        end
        
        client.emit "Fix to temp_hp done."
        
      end

    end
  end
end
