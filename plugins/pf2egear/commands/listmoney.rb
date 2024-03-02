module AresMUSH
  module Pf2egear
    class PF2ListMoneyCmd
      include CommandHandler

      attr_accessor :character

      def parse_args
        self.character = upcase_arg(cmd.args)
      end

      def check_permissions
        # Any character may view their own; only people who can see alts can see others'.

        return nil if !self.character
        return nil if enactor.has_permission?('manage_alts')
        return t('dispatcher.not_allowed')
      end

      def handle

        char = Pf2e.get_character(self.character, enactor)

        paginator = Paginator.paginate(char.pf2_money_history, cmd.page, 10)
        if (paginator.out_of_bounds?)
          client.emit_failure paginator.out_of_bounds_msg
          return
        end

        template = PF2MoneyHistoryTemplate.new(char, paginator, client)

        client.emit template.render

      end

    end
  end
end
