module AresMUSH
  module Pf2emagic

    def self.get_focus_casting_stat(stype)
      Global.read_config('pf2e_magic', 'focus_casting_stat', stype)
    end

    def self.cast_spell(char, charclass, level=nil, spell, target_list, spell_type)
      return t('pf2emagic.not_caster') unless Pf2emagic.is_caster?(char)

      # Caster type starts as spell type but can be overridden.
      caster_type = spell_type
      cc = (charclass == 'innate') ? charclass : charclass.capitalize
      magic = char.magic

      # Spell_type can be 'focus', 'focusc', 'signature', or false. If false,
      # the code expects a full casting class.
      case spell_type
      when false
        caster_type = Pf2emagic.get_caster_type(cc)

        caster_stats = get_caster_stats(char, cc)
      when 'focus', 'focusc'
        # Before we do anything - are you an oracle, and if so, are you revelation locked?
        revelation_lock = charclass == 'Oracle' ? magic.revelation_locked : false

        return t('pf2emagic.revelation_locked') if revelation_lock

        # is_focus is the type of spell and is determined by charclass.
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

      spell_details = Global.read_config('pf2e_spells', spell_name)
      base = spell_details['base_level']

      splevel = level ? level : base

      # If specified, level must be at least the base level of the spell. Level is an integer here.
      return t('pf2emagic.invalid_level') if (level && (level < base))

      splevel = 'cantrip' if splevel.zero?

      # Does the character have this spell available to cast today?

      case caster_type
      when 'prepared'
        # Is that spell name prepared at that level today?
        cc_spells_2day = magic.spells_today[charclass]
        splist = cc_spells_2day[splevel]
        available = splist.include? spell_name
        return t('pf2emagic.not_prepared_at_level') unless available
      when 'spontaneous'
        # Got a spell open at that level?
        cc_spells_2day = magic.spells_today[charclass]
        slots = cc_spells_2day[splevel]
        available = (slots > 0)
        return t('pf2emagic.no_available_slots') unless available
      when 'focus'
        # Check for both pool available and, in the case of Oracle, revelation lock.
        pool = magic.focus_pool['current']

        available = (pool > 0)
        return t('pf2emagic.not_enough_focus_points') unless available
      when 'signature'
        # Signature means that you can cast that spell at the level you know it at, at its base level, or any
        # level in between.
        cc_spells_2day = magic.spells_today[charclass]
        slots = cc_spells_2day[splevel]
        signature_spells = magic.signature_spells[charclass]
        lvfloor = spell_details['base_level']
        lvceil = signature_spells.invert[spell_name]

        available = lvceil && splevel.to_i.between?(lvfloor, lvceil) && (slots > 0)
        return t('pf2emagic.invalid_signature_level') unless available
      else
        # Focus cantrips and innate spells don't use slots, so they are always available.
        available = true
      end

      # Pause point: deduct the spell


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
