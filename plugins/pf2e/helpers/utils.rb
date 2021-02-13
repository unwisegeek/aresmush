module AresMUSH
  module Pf2e

    def self.find_character_ability(char, type, name)
      case type.downcase
      when 'ability'
        element_list = char.abilities
      when 'skill'
        element_list = char.skills
      when 'lore'
        element_list = char.lores
      else
        element_list = nil
      end

      return nil if !element_list
      element = element.select { |a| a.name == name }
    end

    def self.get_prof_bonus(p="untrained")
      levels = { "untrained"=>0, "trained"=>2, "expert"=>4, "master"=>6, "legendary"=>8 }
      bonus = levels[p]
    end

    def self.roll_dice(amount=1, sides=20)
      result = amount.to_i.times { |t| rand(1..sides.to_i) }
      total = result.sum
      return [ result, total ]
    end

    def self.character_has?(array, element)
      array.include?(element)
    end

    def self.character_has_index?(array, element)
      if array.include?(element)
        return array.index(element)
      else
        return false
      end
    end

    def self.find_feat(type,term)

    end

  end
end
