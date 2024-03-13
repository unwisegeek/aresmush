module AresMUSH
  module Pf2emagic

    def self.get_focus_casting_stat(stype)
      Global.read_config('pf2e_magic', 'focus_casting_stat', stype)
    end

    def self.cast_spell(char, charclass, level=nil, spell, target_list, spell_type)
      return t('pf2emagic.not_caster') unless Pf2emagic.is_caster?(char)

      cc = (charclass == 'innate') ? charclass : charclass.capitalize
      caster_type = nil

      # Spell_type can be 'focus', 'focusc', 'signature', or false. If false,
      # the code expects a full casting class.
      case spell_type
      when false
        caster_type = Pf2emagic.get_caster_type(cc)

        caster_stats = get_caster_stats(char, cc)
      when 'focus', 'focusc'
        # If this is true, is_focus is the type of spell and is determined by charclass

        is_focus = Global.read_config('pf2e_magic', 'focus_type_by_class', cc)
        caster_stats = get_caster_stats(char, cc, is_focus)
      when 'signature'
        caster_stats = get_caster_stats(char, cc)
      else
        return t('pf2e.bad_switch', :cmd => 'cast')
      end

      # get_caster_stats returns a Hash if successful, a string if not
      return caster_stats if caster_stats.is_a? String

      spell_result = Pf2emagic.get_spells_by_name(spell)

      return t('pf2emagic.no_match', :item => "spells") if spell_result.empty?
      return t('pf2e.multiple_matches', :element => 'spell') if spell_result.size > 1

      spell_name = spell_result.first

      # Does the character have this spell available to cast today?

      case caster_type
      when 'prepared'
      when 'spontaneous'
      else
      end




    end

    def self.get_caster_stats(char, charclass, is_focus=false)
      magic = char.magic

      # Can this character cast as this class?

      cast_stats = magic.tradition[charclass]
      return t('pf2emagic.not_casting_class', :cc => charclass) unless cast_stats

      spell_abil = PF2Magic.get_spell_abil(char, charclass, is_focus)
      tradition = cast_stats[0]
      prof_level = cast_stats[1]
      modifier = Pf2eAbilities.abilmod(Pf2eAbilities.get_score(char, spell_abil))

      # Return a hash of all the pieces of their casting stats for that class.

      {
        'tradition' => tradition,
        'prof_level' => prof_level,
        'spell_abil' => spell_abil,
        'modifier' => modifier
      }

    end

  end
end
