module AresMUSH
  module Pf2e

    class PF2AdvanceSpellCmd
      include CommandHandler

      attr_accessor :type, :value

      def parse_args
        args = cmd.parse_args(ArgParser.arg1_equals_arg2)

        self.type = downcase_arg(args.arg1)
        self.value = trim_arg(args.arg2)
      end

      def check_advancing
        return nil if enactor.advancing
        return t('pf2e.not_advancing')
      end

      def handle
        # Do they have one of these to select?

        to_assign = enactor.pf2_to_assign

        magic_options = to_assign['magic options']

        unless magic_options
          client.emit_failure t('pf2e.adv_not_an_option')
          return
        end

        type_option = magic_options[self.type]

        unless type_option
          client.emit_failure t('pf2e.adv_not_an_option')
          return
        end



      end
    end
  end
end
