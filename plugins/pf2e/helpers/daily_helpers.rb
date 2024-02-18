module AresMUSH
  module Pf2e

    def self.do_daily_prep(char)
      return t('pf2e.not_approved') unless char.is_approved? 

      # Check for 24h since last refresh
      last_refresh = char.pf2_last_refresh
      current_time = Time.now

      elapsed = (current_time - last_refresh).to_i

      if elapsed < 86400
        next_refresh = OOCTime.local_long_timestr(char, Time.at(last_refresh + 86400))

        return t('pf2e.cannot_rest_time', :next => next_refresh)
      end

      magic = char.magic

      # Healing
      Pf2eHP.modify_damage(char, char.pf2_level, true)

      # Focus Pool
      daily_refresh_focus_pool(magic) if magic

      # Reagents
      daily_refresh_reagents(char)

      # Spells 
      Pf2emagic.generate_spells_today(char) if magic

      # Handle Swaps 

      # Reset revelations 
      magic.update(revelation_locked: false) if magic

      char.update(pf2_last_refresh: Time.now)

      return nil
    end

    def self.do_refresh(char)
      reset = Time.at(0)

      char.update(pf2_last_refresh: reset)
    end

    def daily_refresh_reagents(char)
      # Reagents structure: 
      # For alchemists, alchemist: [total, allocated, remaining]
      # For snares, snares: [total, remaining]

      reagents = char.pf2_reagents
      return nil unless reagents
      return nil if reagents.empty?

      alchemist = reagents['alchemist']
      snares = reagents['snares']
      if alchemist
        int_mod = Pf2eAbilities.abilmod(Pf2eAbilities.get_score(char, "Intelligence"))
        cl = char.pf2_level

        is_alchemist = char.pf2_base_info['charclass'] == "Alchemist"

        total = is_alchemist ? (cl + int_mod) : cl

        allocated = char.pf2_alloc_reagents

        reagents['alchemist'] = [ total, allocated, (total - allocated) ]

      elsif snares
        crafting_prof = get_skill_prof(char, Crafting)

        proflist = [ expert, master, legendary ]
        quick_snares = [ 4, 6, 8 ]

        snares_today = quick_snares[proflist.index(crafting_prof)]

        reagents['snares'] = [ snares_today, snares_today ]
      end

      char.update(pf2_reagents: reagents)

    end

    def daily_refresh_focus_pool(magic)
      fp = magic.focus_pool

      current = fp['max']

      fp['current'] = current

      magic.update(focus_pool: fp)
    end

  end
end