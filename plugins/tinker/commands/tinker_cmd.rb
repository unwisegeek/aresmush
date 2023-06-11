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
        
        char_wp_list = Pf2egear.items_in_inventory(char.weapons.to_a)
        char_a_list = Pf2egear.items_in_inventory(char.armor.to_a)
        char_mi_list = Pf2egear.items_in_inventory(char.magic_items.to_a)

        investable_list = char_wp_list + char_a_list + char_mi_list
        
        client.emit investable_list

        already_invested = investable_list.select {|i| i.invest_on_refresh }.to_a
        
        client.emit already_invested

        counter = already_invested.size
        
        client.emit counter
        
        
        
      end

    end
  end
end
