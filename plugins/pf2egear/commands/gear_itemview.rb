module AresMUSH
  module Pf2egear
    class PF2ItemViewCmd
      include CommandHandler

      attr_accessor :category, :item_id

      def parse_args
        args = cmd.parse_args(ArgParser.arg1_equals_arg2)
        self.category = downcase_arg(args.arg1)
        self.item_id = integer_arg(args.arg2)

        @numcheck = trim_arg(args.arg2)
      end

      def check_valid_category
        cats = %w(weapons weapon armor shields shield magicitem)

        return nil if cats.include?(self.category)
        return t('pf2egear.bad_category')
      end

      def check_is_number
        return nil if @numcheck.to_i.to_s == @numcheck
        return t('pf2egear.must_specify_by_number')
      end

      def handle

        # Identify the item to be viewed.

        index = self.item_id

        case category
        when "weapons", "weapon"
          item = Pf2egear.items_in_inventory(enactor.weapons).to_a[index]
        when "armor"
          item = Pf2egear.items_in_inventory(enactor.armor).to_a[index]
        when "shields", "shield"
          item = Pf2egear.items_in_inventory(enactor.shields).to_a[index]
        when "magicitem"
          item = Pf2egear.items_in_inventory(enactor.magic_items).to_a[index]
        end

        template = Pf2eDisplayItemTemplate.new(char, item, client)

        client.emit template.render

      end

    end
  end
end
