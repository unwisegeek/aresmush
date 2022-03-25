module AresMUSH
  module Pf2egear
    class PF2BagStoreCmd
      include CommandHandler

      attr_accessor :bag_id, :category, :item_id, :item_name

      def parse_args
        args = cmd.parse_args(ArgParser.arg1_slash_arg2_equals_arg3)
        self.bag_id = trim_arg(args.arg3)
        self.category = downcase_arg(args.arg1)
        self.item_id = integer_arg(args.arg2)
        self.item_name = upcase_arg(args.arg2)

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
        return nil if self.category == ("gear" || "consumables")
        return nil if @numcheck.to_i.to_s == @numcheck
        return t('pf2egear.must_specify_by_number')
      end

      def handle

        # Did they specify the bag by number or by name? Either is legal.

        # Either way, bag is the Ohm object ID of the bag.
        bag_by_number = self.bag_id.to_i.to_s == self.bag_id

        if bag_by_number
          bagindex = self.bag_id.to_i

          bag = enactor.bags.to_a[bagindex]
        else
          bag_list = enactor.bags.select {|b| b.name.downcase == self.bag_id.downcase }

          if bag_list.size.zero?
            client.emit_failure t('pf2egear.not_found')
            return
          elsif bag_list.size > 1
            client.emit_failure t('pf2egear.ambiguous_item')
            return
          else
            bag = bag_list.first
          end
        end

        if !bag
          client.emit_failure t('pf2egear.bag_not_found')
          return
        end

        # Get the correct list of items based on category.

        case self.category
        when "weapon", "weapons"
          item = Pf2egear.items_in_inventory(enactor.weapons.to_a)[self.item_id]
        when "armor"
          item = Pf2egear.items_in_inventory(enactor.armor.to_a)[self.item_id]
        when "shield", "shields"
          item = Pf2egear.items_in_inventory(enactor.shields.to_a)[self.item_id]
        when "magicitem", "magicitems"
          item = Pf2egear.items_in_inventory(enactor.magicitems.to_a)[self.item_id]
        when "consumables", "gear"
          gear_list = enactor.pf2_gear

          gear_list_cat = gear_list[category]

          item_list = gear_list_cat.select { |k,v| k.upcase.match == self.item_name }

          if item_list.size.zero?
            client.emit_failure t('pf2egear.not_found')
            return
          elsif item_list.size > 1
            client.emit_failure t('pf2egear.ambiguous_item')
            return
          else
            itemname = item_list.keys.first
            item_qty = item_list.values.first
          end
        end

        if !(item || itemname)
          client.emit_failure t('pf2egear.not_found')
          return
        end

        # All right, time to move the item.

        if item
          item.update(bag: bag)
        elsif itemname
          # Update the bag.
          bag_contents = bag.gear_contents

          bag_contents_cat = contents[self.category]
          bag_contents_cat[item_name] = item_qty
          bag_contents[self.category] = contents_cat
          bag.update(gear_contents: contents)

          # Update the user's main inventory.

          gear_list_cat.delete(itemname)

          gear_list[category] = gear_list_cat

          enactor.update(pf2_gear: gear_list)

        end

        stored_item = item ? item.name : itemname

        client.emit_success t('pf2egear.bag_store_ok', :name => stored_item, :bag => bag.name)
      end

    end
  end
end
