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
        hp = char.hp
        
        hp.update(max_base: 16)
        
        client.emit "Done - #{hp.max_base}"
        
      end

    end
  end
end
