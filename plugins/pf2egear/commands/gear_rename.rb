module AresMUSH
  module Pf2egear
    class PF2GearRenameCmd
      include CommandHandler

      attr_accessor :category, :item_num, :nickname

      def parse_args
        args = cmd.parse_args(ArgParser.arg1_slash_arg2_equals_arg3)

        self.category = downcase_arg(args.arg1)
        self.item_num = integer_arg(args.arg2)
        self.nickname = trim_arg(args.arg3)
      end

      def required_args
        [ self.category, self.item_num, self.nickname ]
      end

      def check_valid_category
        cats = %w(weapons weapon armor shields shield)

        return nil if cats.include?(self.category)
        return t('pf2egear.bad_category')
      end

      def handle

        case self.category
        when "weapon", "weapons"
          item_list = enactor.weapons

          item_class = "AresMUSH::PF2Weapon"
        when "armor"
          item_list = enactor.armor

          item_class = "AresMUSH::PF2Armor"
        when "shield", "shields"
          item_list = enactor.shields

          item_class = "AresMUSH::PF2Shield"
        end
        # Does item_num exist in category?

        item = item_list.to_a[self.item_num].first

        client.emit_ooc item

        if !item
          client.emit_failure t('pf2egear.not_found')
          return
        end

        # Give the item its nickname.
        item.update(nickname: self.nickname)

        client.emit_success t('pf2egear.item_rename_ok', :name => item.name, :nickname => self.nickname)
      end

    end
  end
end
