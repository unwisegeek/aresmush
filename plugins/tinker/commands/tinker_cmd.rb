module AresMUSH
  module Tinker
    class TinkerCmd
      include CommandHandler
      
      def check_can_manage
        return t('dispatcher.not_allowed') if !enactor.has_permission?("tinker")
        return nil
      end
      
      def handle
        value = AresMUSH::Pf2eAbilities.get_ability_mod(13)
        
        client.emit value
      end

    end
  end
end
