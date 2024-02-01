module AresMUSH
  module Pf2emagic

    class PF2ChargenSpellsCmd
      include CommandHandler

      attr_accessor :caster_class, :spell_level, :new_spell, :old_spell, :is_spell_swap

      def parse_args
        args = cmd.parse_args(ArgParser.arg1_slash_arg2_equals_arg3)

        self.caster_class = trim_arg(args.arg1)
        self.spell_level = trim_arg(args.arg2)

        spells = trimmed_list_arg(args.arg3, /)

        if spells[1]
          self.new_spell = spells[1]
          self.old_spell = spells[0]
          self.is_spell_swap = true
        else
          self.new_spell = spells[0]
          self.is_spell_swap = false
        end
      end

      def required_args
        [ self.caster_class, self.spell_level, self.new_spell]
      end

      def check_valid_swap_syntax
        return nil unless self.is_spell_swap
        return nil if self.old_spell
        return t('pf2emagic.bad_spell_swap_syntax')
      end

      def handle

      end

    end

  end
end
