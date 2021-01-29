module AresMUSH
  module Tinker
    class TinkerCmd
      include CommandHandler
      
      def check_can_manage
        return t('dispatcher.not_allowed') if !enactor.has_permission?("tinker")
        return nil
      end
      
      def handle
        mod = Pf2e.get_ability_mod(10)
        
        client.emit mod

      end

    end
  end
end
