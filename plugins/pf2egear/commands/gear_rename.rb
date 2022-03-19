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
        [ self.category, self.item_num ]
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
        when "armor"
          item_list = enactor.armor
        when "shield", "shields"
          item_list = enactor.shields
        end

        # Does item_num exist in category?

        item = item_list.to_a[self.item_num]

        if !item
          client.emit_failure t('pf2egear.not_found')
          return
        end

        # Give the item its nickname.
        item.update(nickname: self.nickname)

        succ_msg = self.nickname ?
          t('pf2egear.item_rename_ok', :name => item.name, :nickname => self.nickname) :
          t('pf2egear.item_removename_ok')

        client.emit_success succ_msg
      end

    end
  end
end
