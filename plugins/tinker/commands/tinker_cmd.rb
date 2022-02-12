module AresMUSH
  module Tinker
    class TinkerCmd
      include CommandHandler
      
      def check_can_manage
        return t('dispatcher.not_allowed') if !enactor.has_permission?("tinker")
        return nil
      end
      
      def handle
        lore_list = Global.read_config('pf2e_lores')
        lore_types = lore_list.keys
        
        type = 'crafting'
        
        client.emit lore_list
        client.emit lore_types
        
        lore_list = lore_list.keep_if { |k,v| k == type }
        
        client.emit lore_list
      end

    end
  end
end
