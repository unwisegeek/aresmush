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

        self.item_list.each do |i|
            list << char_inventory[i]
        end

        invest_list = list.compact

        if invest_list.empty?
          client.emit_failure t('pf2egear.nothing_to_do')
          return
        end

        if (invest_list !== list)
          client.emit_ooc t('pf2egear.bad_item_in_list')
        end

        # Invest the items that are valid.

        invest_list.each { |i| i.update(invested: true) }

        client.emit_success t('pf2egear.items_invested_ok', :count => invest_list.count)
      end

    end
  end
end
