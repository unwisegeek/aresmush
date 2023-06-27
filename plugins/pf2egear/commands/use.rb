module AresMUSH
  module Pf2egear
    class PF2UseItemCmd
      include CommandHandler

      attr_accessor :category, :item_num, :use_options

      def parse_args
        args = cmd.parse_args(ArgParser.arg1_slash_arg2)

        self.category = downcase_arg(args.arg1)
        second_parse = trimmed_list_arg(args.arg2, "=")
        self.item_num = second_parse ? integer_arg(second_parse[0]) : nil
        self.option = second_parse ? trim_arg(second_parse[1]) : nil

        @numcheck = trim_arg(second_parse[0]) if second_parse
      end

      def required_args
        [ self.category, self.item_num ]
      end

      def check_valid_category
        return nil if [ "weapons", "weapon", "armor", "magicitem", "consumable", "consumables" ].include?(self.category)
        return t('pf2egear.bad_category')
      end

      def check_is_number
        return nil if @numcheck.to_i.to_s == @numcheck
        return t('pf2egear.must_specify_by_number')
      end

      def handle
        # Start by finding the item to be used. 

        case self.category
        when "weapon", "weapons"
          item_list = Pf2egear.items_in_inventory(enactor.weapons.to_a)
        when "consumable", "consumables"
          item_list = Pf2egear.items_in_inventory(enactor.consumables.to_a)
        when "armor"
          item_list = Pf2egear.items_in_inventory(enactor.armor.to_a)
        when "magicitem"
          item_list = Pf2egear.items_in_inventory(enactor.weapons.to_a)
        else 
          client.emit_failure t('pf2egear.bad_category')
          return
        end

        # Does item_num exist in category?

        item = item_list[self.item_num]

        if !item
          client.emit_failure t('pf2egear.not_found')
          return
        end

        # Is this a usable item? 

        use = item.use

        if use.empty?
          client.emit_failure t('pf2egear.not_usable')
          return
        end

        # For armor and weapons, you can only use it if it's equipped.
        # Magic items can only be used if they are invested first. 

        case self.category
        when "weapon", "weapons", "armor"
          if !item.equipped
            client.emit_failure t('pf2egear.cannot_use_now', :action => 'equipped')
            return
        when "magicitem"
          if !item.invested
            client.emit_failure t('pf2egear.cannot_use_now', :action => 'invested')
            return
          end
        end

        # Consumables get their own, much simpler, handling. 

        if item.instance_of? PF2Consumable

          template = PF2UseItemTemplate.new(enactor, item, {})
          message = template.render

          enactor_room.emit message

          scene = enactor_room.scene
          if scene
            Scenes.add_to_scene(scene, message)
          end

          new_quantity = item.quantity - 1

          if new_quantity.zero?
            Pf2egear.destroy_item(item)
          else
            item.update(quantity: new_quantity)
          end

          return
        end

        # Some items have more than one use. Expect a valid self.option if this is the case. 

        uses = use.keys

        if uses.size > 1 && !self.option
          client.emit_failure t('pf2egear.needs_use_option', :options => uses.keys.sort.join(", "))
          return
        end

        if !(uses.include? self.option)
          client.emit_failure t('pf2egear.bad_use')
          return
        end

        selected_use = self.option ? uses[self.option] : uses.first

        details = use[selected_use]

        template = PF2UseItemTemplate.new(enactor, item, details)
        message = template.render

        enactor_room.emit message

        scene = enactor_room.scene
        if scene
          Scenes.add_to_scene(scene, message)
        end

        # Now that the item has been used, can it be used again? If not, destroy it.

        if details['charges']
          charges = details['charges'] - 1

          if charges.zero?
            use.delete(selected_use)
          else 
            details['charges'] = charges
            use[selected_use] = details
          end

          item.update(use: use)

          if use.empty?
            Pf2egear.destroy_item(item) 
          end

        end




      end

    end
  end
end