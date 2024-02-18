module AresMUSH
  module Pf2noms

    def self.calculate_max_alts(player)
      tierlist = Global.read_config('pf2noms', 'rpp_alt_tiers')
      base_alts = 2
      player_rpp = player.total_rpp

      addl_alts = tierlist.rindex { |a| a < player_rpp }
      addl_alts = 0 unless addl_alts

      base_alts + addl_alts
    end

    def self.calculate_current_alts(player)
      altlist = player.characters

      # Staff bits need to register to receive RPP but do not count against the alt limit.

      altlist.select { |a| !(a.is_admin?) }.size
    end

    def do_nom_refresh(char)
      player = char.player

      return nil unless player

      noms_for_week = Global.read_config('pf2noms', 'noms_per_week')

      player.update(nomlist: [])
      player.update(totalnoms: noms_for_week)

    end

  end
end
