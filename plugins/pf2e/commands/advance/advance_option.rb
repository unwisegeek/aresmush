module AresMUSH
  module Pf2e

    class PF2AdvanceRaiseCmd
      include CommandHandler

      attr_accessor :type, :value

      def parse_args
        args = cmd.parse_args(ArgParser.arg1_equals_arg2)

        self.type = downcase_arg(args.arg1)
        self.value = upcase_arg(args.arg2)
      end

      def required_args
        [ self.type, self.value ]
      end

      def check_advancing
        return nil if enactor.advancing
        return t('pf2e.not_advancing')
      end

      def handle

      end
    end
  end
end
