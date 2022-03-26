module AresMUSH
  module Pf2egear
    class PF2BagRetrieveCmd
      include CommandHandler

      attr_accessor :bag_id, :category, :item_id

      def parse_args
        args = cmd.parse_args(ArgParser.arg1_slash_arg2_equals_arg3)
        self.bag_id = integer_arg(args.arg3)
        self.category = downcase_arg(args.arg1)
        self.item_id = integer_arg(args.arg2)

        @numcheck = trim_arg(args.arg2)
      end

      def required_args
        [ self.bag_id, self.category, self.item_id ]
      end

      def check_valid_category
        cats = %w(weapons weapon armor shields shield magicitem magicitems gear consumables)

        return nil if cats.include?(self.category)
        return t('pf2egear.bad_category')
      end

      def check_is_number
        return nil if @numcheck.to_i.to_s == @numcheck
        return t('pf2egear.must_specify_by_number')
      end

      def handle

        bag = enactor.bags.to_a[self.bag_id]

        if !bag
          client.emit_failure t('pf2egear.bag_not_found')
          return
        end

        # Get the correct list of items based on category.

        case self.category
        when "weapon", "weapons"
          item = bag.weapons.to_a[self.item_id]
        when "armor"
          item = bag.armor.to_a[self.item_id]
        when "shield", "shields"
          item = bag.shields.to_a[self.item_id]
        when "magicitem", "magicitems"
          item = bag.magicitem.to_a[self.item_id]
        when "consumables"
          item = bag.consumables.to_a[self.item_id]
        when "gear"
          item = bag.gear.to_a[self.item_id]
        end

        if !item
          client.emit_failure t('pf2egear.not_found')
          return
        end

        # Move the item.

        item.update(bag: nil)

        client.emit_success t('pf2egear.bag_retrieve_ok', :name => item.name, :bag => bag.name)
      end

    end
  end
end
