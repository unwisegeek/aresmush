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
        self.use_options = trim_arg(second_parse[1])

        @numcheck = trim_arg(second_parse[0])
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
        client.emit self.item_num
        client.emit self.use_options

      end

    end
  end
end