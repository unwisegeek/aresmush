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
        
        to_assign = char.pf2_to_assign
        
        client.emit to_assign
        
        client.emit to_assign.empty?

      end

    end
  end
end
