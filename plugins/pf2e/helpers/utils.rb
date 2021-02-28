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
      element = element_list.select { |a| a.name_upcase == name.upcase }
    end

    # p can be passed to this method as nil
    def self.get_prof_bonus(p="untrained")
      levels = { "untrained"=>0, "trained"=>2, "expert"=>4, "master"=>6, "legendary"=>8 }
      bonus = levels[p]
    end

    def self.get_linked_attr_mod(char, value, type=nil)
      case type.downcase
      when 'skill'
        return Pf2eAbilities.get_ability_mod(Pf2eAbilities.get_ability_score(char, Pf2eSkills.get_linked_attr value))
      when 'lore'
        return Pf2eAbilities.get_ability_mod(Pf2eAbilities.get_ability_score char, 'Intelligence')
      else
        case value.downcase
        when 'fort', 'fortitude'
          return Pf2eAbilities.get_ability_mod(Pf2eAbilities.get_ability_score char, 'Constitution')
        when 'ref', 'reflex', 'ranged', 'finesse'
          return Pf2eAbilities.get_ability_mod(Pf2eAbilities.get_ability_score char, 'Dexterity')
        when 'will', 'perception'
          return Pf2eAbilities.get_ability_mod(Pf2eAbilities.get_ability_score char, 'Wisdom')
        when 'melee'
          return Pf2eAbilities.get_ability_mod(Pf2eAbilities.get_ability_score char, 'Strength')
        else
          nil
        end
      end
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

    def self.get_level_tier(level)
      1 + level / 5
    end

    def self.bonus_from_item(char, type)
      return nil
    end

  end
end
