module AresMUSH
  module Pf2egear
    class PF2SellCmd
      include CommandHandler

      attr_accessor :category, :item_name, :quantity, :item_num

      def parse_args
        args = cmd.parse_args(ArgParser.arg1_equals_arg2_slash_optional_arg3)
        self.category = downcase_arg(args.arg1)
        self.item_num = integer_arg(args.arg2)
        self.item_name = upcase_arg(args.arg2)
        self.quantity = integer_arg(args.arg3)
      end

      def required_args
        [ self.category, self.item_num ]
      end

      # def check_permissions
        # return nil if enactor.is_approved?
        # return nil if enactor.is_admin?
        # return t('pf2egear.approved_players_only')
      # end

      def check_valid_quantity
        return nil if !self.quantity
        return nil if self.quantity.positive?
        return t('pf2egear.bad_quantity')
      end

      def handle

        # If no quantity is specified, assume 1
        q = self.quantity ? self.quantity : 1

        list_key = "pf2e_" + self.category

        # Valid category of items?
        list = Global.read_config(list_key)

        if !list
          client.emit_failure t('pf2egear.bad_category')
          return
        end

        # Find the item in the list. How to do that depends on the category.
        index = self.item_num

        case category
        when "weapons"
          item_id = enactor.weapons.to_a[index]
        when "armor"
          item_id = enactor.armor.to_a[index]
        when "shields"
          item_id = enactor.shields.to_a[index]
        when "bags"
          item_id = enactor.bags.to_a[index]
        when "magicitem"
          item_id = enactor.weapons.to_a[index]
        when "consumables", "gear"
          gear_list = enactor.pf2_gear[category]

          item = gear_list.select { |k,v| k.upcase.match == self.item_name }

          if item.size.zero?
            client.emit_failure t('pf2egear.not_found')
            return
          elsif item.size > 1
            client.emit_failure t('pf2egear.ambiguous_item')
            return
          else
            itemname = item.keys.first
            item_qty = gear_list[item_name]['quantity']
          end
        end

        if !(item_id || itemname)
          client.emit_failure t('pf2egear.not_found')
          return
        end

        purse = enactor.pf2_money

        if item_id
          itemname = item_id.name
          price = (item_id.price) / 2
          item_id.delete
        else
          if q > item_qty
            client.emit_failure t('pf2egear.not_enough_you', :item => "of those to sell #{q}")
            return
          else
            price = list[itemname]['price'] * (item_qty - q)

            # If they're selling all of them, blow the item out of the list, else subtract quantity
            if q == item_qty
              gear_list.delete[itemname]
            else
              gear_list[itemname]['quantity'] = (item_qty - q)
            end
          end
        end

        enactor.update(pf2_money: purse + price)


        Pf2e.record_history(enactor, 'money', 'Item Vendor', price, "Item Sale: #{itemname}")

        client.emit_success t('pf2egear.item_sold_ok', :item => itemname, :cost => Pf2egear.display_money(price), :quantity => q)

      end

    end
  end
end
