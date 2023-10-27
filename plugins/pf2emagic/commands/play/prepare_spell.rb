module AresMUSH
  module Pf2emagic
    class PF2PrepareSpellCmd
      include CommandHandler

      def parse_args
        args = cmd.parse_args(ArgParser.arg1_equals_arg2)

        parse_arg_1 = args.arg1.split("/")

        self.caster_class = trim_arg(parse_arg_1[0])
        self.spell_level = integer_arg(parse_arg_1[1])
        self.spell_name = titlecase_arg(args.arg2)
      end

      def required_args
        [ self.caster_class, self.spell_name ]
      end

      def check_valid_spell

      end

      def check_is_approved

      end

      def handle

      end


    end
  end
end
