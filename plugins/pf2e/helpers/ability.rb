module AresMUSH
  module Pf2e
    class Pf2eAbilities

      def self.get_ability_mod(score)
        (score - 10) / 2
      end

      def self.get_ability_score(char, ability)
        object = Pf2e.find_character_ability(char, 'ability', ability)
        score = object.mod_val ? object.mod_val : object.base_val
      end

    end
  end
end
