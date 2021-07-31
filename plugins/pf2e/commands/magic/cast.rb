module AresMUSH
  module Pf2e
    class PF2CastCmd
      include CommandHandler

      def parse_args
        args = cmd.parse_args(ArgParser.arg1_slash_arg2_equals_arg3)
        getspell = args.arg3.partition("at")

        self.charclass = downcase_arg(args.arg1)
        self.level = integer_arg(args.arg2)
        self.spell = getspell[0]
        self.target = getspell[2]
      end

      def required_args
        [ self.charclass, self.level, self.spell ]
      end

      def handle
        # Can you even cast spells at all?
        magic = Pf2eMagic.get_magic_obj(enactor)

        if !magic
          client.emit_failure t('pf2e.not_caster')
          return
        end

        # Can you cast spells from the specified character class?

        if !magic.tradition[self.charclass]
          client.emit_failure t('pf2e.cannot_cast_charclass')
          return
        end

        # Can you cast spells of the desired level?

        if magic.max_spell_level < self.level
          client.emit_failure t('pf2e.cannot_cast_spell_level')
          return
        end

        # Is the desired spell in your ready list, or in your repertoire, at that level?
        # Not bothering to check for spell exist? here, will not be in the ready list if it does not exist.

        spell_name = Pf2e.pretty_string(self.spell)

        if !(ready_list[self.level].include? spell_name)
          client.emit_failure t('pf2e.spell_not_in_list')
          return
        end

        tradition = magic.tradition[self.charclass][0]

        template = Pf2eCastSpellTemplate.new(enactor, spell_name, tradition, self.level, self.target)

        Scenes.emit_pose(Game.master.system_character, template.render, true, false, nil, true)

      end

    end
  end
end
