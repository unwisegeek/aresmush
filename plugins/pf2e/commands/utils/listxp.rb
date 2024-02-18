module AresMUSH
  module Pf2e
    class PF2ListXPCmd
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

        # If no argument, code assumes reference is to self.

        char = Pf2e.get_character(self.character, enactor)

        if !char
          client.emit_failure t('pf2e.not_found')
          return
        end

        paginator = Paginator.paginate(char.pf2_xp_history, cmd.page, 10)
        if (paginator.out_of_bounds?)
          client.emit_failure paginator.out_of_bounds_msg
          return
        end

        template = PF2XPHistoryTemplate.new(char, paginator, client)

        client.emit template.render

      end


    end
  end
end