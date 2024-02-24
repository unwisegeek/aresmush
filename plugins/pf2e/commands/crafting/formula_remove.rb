module AresMUSH
  module Pf2e

    class PF2FormulaRemoveCmd
      include CommandHandler

      attr_accessor :character, :category, :name

      def parse_args
        args = cmd.parse_args(ArgParser.arg1_equals_arg2_slash_arg3)

        self.character = trim_arg(args.arg1)
        self.category = downcase_arg(args.arg2)
        self.name = trim_arg(args.arg3)
      end

      def required_args
        [ self.character, self.category, self.name ]

      end

      def check_permissions
        return nil if enactor.has_permission?("manage_sheet")
        return t('dispatcher.not_allowed')
      end

      def handle

        char = PF2e.get_character(self.character, enactor)

        if !char
          client.emit_failure t('pf2e.not_found')
          return
        end

        msg = PF2e.update_formula(char, self.category, self.name, true)

        if msg
          client.emit_failure msg
          return
        end

        client.emit_success t('pf2e.updated_ok', :element => 'Formulas', :char => char.name)
      end

    end
  end
end