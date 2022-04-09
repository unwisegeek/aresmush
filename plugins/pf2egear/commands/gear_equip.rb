module AresMUSH
  module Pf2egear
    class PF2GearEquipCmd
      include CommandHandler

      attr_accessor :category, :item_num

      def parse_args
        args = cmd.parse_args(ArgParser.arg1_equals_arg2)

        self.category = downcase_arg(args.arg1)
        self.item_num = integer_arg(args.arg2)

        @numcheck = trim_arg(args.arg2)
      end

      def required_args
        [ self.category, self.item_num ]
      end

      def check_valid_category
        cats = %w(weapons weapon armor shields shield)

        return nil if cats.include?(self.category)
        return t('pf2egear.bad_category')
      end

      def check_is_number
        return nil if @numcheck.to_i.to_s == @numcheck
        return t('pf2egear.must_specify_by_number')
      end

      def handle

        case self.category
        when "weapon", "weapons"
          item_list = Pf2egear.items_in_inventory(enactor.weapons.to_a)
        when "armor"
          item_list = Pf2egear.items_in_inventory(enactor.armor.to_a)

          # Can only equip one armor at a time.
          equipped_items = item_list.select { |item| item.equipped }
        when "shield", "shields"
          item_list = Pf2egear.items_in_inventory(enactor.shields.to_a)

          # Can only equip one shield at a time.
          equipped_items = item_list.select { |item| item.equipped }
        end

        # Some categories only allow one item to be equipped at a time.

        if equipped_items
          if !equipped_items.empty?
            client.emit_failure t('pf2egear.already_equipped')
            return
          end
        end

        # Does item_num exist in category?

        item = item_list[self.item_num]

        if !item
          client.emit_failure t('pf2egear.not_found')
          return
        end

        # Equip the item.
        item.update(equipped: true)

        iname = item.nickname ? item.nickname : item.name

        client.emit_success t('pf2egear.item_equip_ok', :name => iname)
      end

    end
  end
end
