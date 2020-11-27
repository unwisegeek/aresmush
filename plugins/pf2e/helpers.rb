module AresMUSH
  module Pf2e

    def find_ability_score(char,ability)
    end

    def find_prof_level(char, ability)
    end

    def get_ability_mod(score)
      mod = (score - 10) / 2
    end

    def get_prof_bonus(p=:untrained)
      levels = { untrained: 0, trained: 2, expert: 4, master: 6, legendary: 8 }
      p = p.to_sym
      bonus = levels[p]
    end

  end
end
