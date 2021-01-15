module AresMUSH
  module Pf2e

    def self.find_ability_score(char,ability)
    end

    def self.find_prof_level(char, target)
    end

    def self.get_ability_mod(score)
      mod = (score - 10) / 2
    end

    def self.get_prof_bonus(p=:untrained)
      levels = { untrained: 0, trained: 2, expert: 4, master: 6, legendary: 8 }
      p = p.to_sym
      bonus = levels[p]
    end

    def self.roll_dice(amount=1, sides=20)
      result = amount.to_i.times { |t| rand(1..sides.to_i) }
      total = result.sum
      return [ result, total ]
    end

  end
end
