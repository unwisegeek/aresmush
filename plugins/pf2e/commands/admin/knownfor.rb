module AresMUSH
  module Pf2e

    class PF2KnownForCmd
      include CommandHandler

      attr_accessor :character, :blurb

      def parse_args
        args = cmd.parse_args(ArgParser.arg1_equals_arg2)

        self.character = trim_arg(args.arg1)
        self.blurb = trim_arg(args.arg2)
      end

      def required_args
        [ self.character, self.blurb ]
      end

      def check_is_admin
        return nil if enactor.is_admin?
        return t('dispatcher.not_allowed')
      end

      def handle

        char = Pf2e.get_character(self.character, enactor)

        char_is_known_for = char.pf2_known_for ? char.pf2_known_for : []

        char_is_known_for << self.blurb

        char.update(pf2_known_for: char_is_known_for)

        client.emit_success t('pf2e.knownfor_set_ok', :name => char.name, :blurb => self.blurb)

      end

    end

  end
end