module AresMUSH
  module Pf2egear
    class PF2BuyCmd
      include CommandHandler

      attr_accessor :category, :item_name, :quantity

      def parse_args
        args = cmd.parse_args(ArgParser.arg1_equals_arg2_slash_optional_arg3)
        self.category = downcase_arg(args.arg1)
        self.item_name = downcase_arg(args.arg2)
        self.quantity = integer_arg(args.arg3)
      end

      def required_args
        [ self.category, self.item_name ]
      end

      def check_permissions
        return nil if enactor.is_approved?
        return nil if enactor.is_admin?
        return t('pf2egear.approved_players_only')
      end

      def check_valid_quantity
        return nil if !self.quantity
        return nil if self.quantity.positive?
        return t('pf2egear.bad_quantity')
      end

      def handle
        charlevel = enactor.pf2_level

        # If no quantity is specified, assume they want just one.
        q = self.quantity ? self.quantity : 1

        list_key = "pf2e" + category

        # Valid category of items?
        list = Global.read_config(list_key)

        if !list
          client.emit_failure t('pf2egear.bad_category')
          return
        end

        # The list of items in that category gets filtered by character level.
        available_items = list.select { |k,v| v['level'] <= charlevel }

        # Does that item exist in that category?
        item = available_items.select { |k,v| k.downcase.match self.item_name }

        if item.size.zero?
          client.emit_failure t('pf2egear.not_found')
          return
        elsif item.size > 1
          client.emit_failure t('pf2egear.ambiguous_item')
          return
        else
          item = item.first
          itemname = item.keys.first
        end

        # Do they have enough money?
        cost = item['price'] * q
        purse = enactor.pf2_money

        if cost > purse
          client.emit_failure t('pf2egear.not_enough_you', :item => 'money to buy that')
          return
        end

        # Some items are classes of their own, some are just stored in the gear list.
        case category
        when "weapon", "armor", "shield", "bag", "magicitem"

        # These types of items are database models of their own.
        source_type = Kernel.const_get(Global.read_config('pf2e_gear_options', 'item_classes', category))
        new_item = source_type.create(character: enactor, name: itemname)

        if quantity > 1
          client.emit_ooc t('pf2egear.quantity_one_only')
        end

        item.values.each_pair do |k,v|
          new_item.update("#{k}": v)
        end

        when "consumable", "gear"
          gear_list = enactor.pf2_gear

          if gear_list.key?(itemname)
            old_quant = gear_list[itemname]
            gear_list[itemname] = old_quant + q
          else
            gear_list[itemname] = q
          end

          enactor.update(pf2_gear: gear_list)

        end

        enactor.update(pf2_money: (purse - cost))

        Pf2e.record_history(enactor, 'money', 'Item Vendor', -cost, "Purchase #{itemname}")

        client.emit_success t('pf2egear.item_bought_ok', :item => itemname, :cost => Pf2egear.display_money(cost), :quantity => q)

      end

    end
  end
end
