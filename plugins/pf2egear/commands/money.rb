module AresMUSH
  module Pf2egear
    class PF2MoneyCmd
      include CommandHandler

      attr_accessor :target

      def parse_args
        self.target = cmd.args
      end

      def check_permissions
        return nil if enactor.is_admin?
        return nil unless self.target
        return t('dispatcher.not_allowed')
      end

      def handle
        char = Pf2e.get_character(self.target, enactor)

        money = Pf2egear.display_money(char.pf2_money)

        client.emit t('pf2egear.money_totals',
          :name => char.name,
          :money => money
        )

      end

    end
  end
end
