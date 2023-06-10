module AresMUSH
  module Tinker
    class TinkerCmd
      include CommandHandler
      
      def check_can_manage
        return t('dispatcher.not_allowed') if !enactor.has_permission?("tinker")
        return nil
      end
      
      def handle
        
        char = Character.find_one_by_name("Testchar")
        
        item_list = Pf2egear.items_in_inventory(char.magic_items.to_a)
        
        client.emit item_list
        
      end

    end
  end
end
