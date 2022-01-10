module AresMUSH
  module Pf2e

    class PF2ChangeRollAliasCmd
      include CommandHandler

      attr_accessor :rollalias, :value

      def parse_args
        args = cmd.parse_args(ArgParser.arg1_equals_optional_arg2)

        self.rollalias = trim_arg(args.arg1)
        self.value = trim_arg(args.arg2)
      end

      def required_args
        [ self.rollalias ]
      end

      # Disabled for playtest
      # def check_approval
        # return nil if (enactor.is_approved?) || (enactor.is_admin?)
        # return t('chargen.not_approved')
      # end

      def check_is_word
        return nil if self.rollalias.to_i.zero?
        return t('pf2e.must_be_word')
      end

      def handle
        list = enactor.pf2_roll_aliases

        if self.value
          list[self.rollalias] = self.value
          client.emit_success t('pf2e.alias_set_ok', :alias => self.rollalias, :value => self.value)
        else
          list.delete(self.rollalias)
          client.emit_success t('pf2e.alias_deleted_ok', :alias => self.rollalias)
        end

        enactor.update(pf2_roll_aliases: list)
      end

    end
  end
end
