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

  end
end
