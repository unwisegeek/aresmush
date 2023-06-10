module AresMUSH
  module Pf2egear
    class PF2GearInvestCmd
      include CommandHandler

      attr_accessor :item_list

      def parse_args
        self.item_list = list_arg(cmd.args)
      end

      def required_args
        [ self.item_list ]
      end

      def check_is_number
        numcheck = self.item_list.map { |n| n.to_i.to_s }

        return nil if self.item_list == numcheck
        return t('pf2egear.must_specify_by_number')
      end

      def handle

        list = []

        char_inventory = Pf2egear.items_in_inventory(enactor.magic_items.to_a)

        # De-invest everything first and reset the list of what is invested.

        char_inventory.each.update(invested: false)

        self.item_list.each do |i|
          list << char_inventory[i]
        end

        invest_list = list.compact

        if invest_list.empty?
          client.emit_failure t('pf2egear.nothing_to_do')
          return
        end

        if (invest_list != list)
          client.emit_ooc t('pf2egear.bad_item_in_list')
        end

        # Handling for weapons that can be invested, e.g. handwraps of mighty blows.
        # If a weapon is equipped, it is considered invested.

        invested_weapons = enactor.weapons.select { |w| w.traits.include? 'invested' && w.equipped }

        # Only 10 items can be invested in a day. 

        if (invest_list + invested_weapons).size > 10
          client.emit_failure t('pf2egear.too_many_invested')
          return
        end

        # Invest the items that are valid.

        invest_list.each { |i| i.update(invested: true) }

        client.emit_success t('pf2egear.items_invested_ok', :count => invest_list.count)
      end

    end
  end
end
