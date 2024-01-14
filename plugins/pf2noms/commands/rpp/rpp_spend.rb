module AresMUSH
  module Pf2noms

    class PF2SpendRPPCmd
      include CommandHandler

      attr_accessor :character, :spend, :reason

      def parse_args
        args = cmd.parse_args(ArgParser.arg1_equals_arg2_slash_optional_arg3)

        self.character = upcase_arg(args.arg1)
        self.spend = integer_arg(args.arg2)
        self.reason = args.arg3 ? args.arg3 : ""

      end

      def required_args
        [ self.character, self.spend ]
      end

      def check_permissions
        return nil if enactor.has_permission?('manage_alts')
        return t('dispatcher.not_allowed')
      end

      def check_valid_number
        return nil unless self.spend.zero?
        return t('pf2noms.not_a_number')
      end

      def handle

        # Valid character?
        char = Character.find_one_by_name(self.character)

        if !char
          client.emit_failure t('pf2e.char_not_found')
          return
        end

        # The helper does the rest of the work, but may throw an error.
        # It will return nil if everything went okay.

        msg = Player.spend_rpp(char, self.spend, self.reason)

        if msg
          client.emit_failure msg
          return
        else
          client.emit_success t('pf2noms.rpp_spend_ok', 
            :spend => self.spend, 
            :char => char.name, 
            :reason => self.reason
            )
        end
        

      end

    end
  end
end