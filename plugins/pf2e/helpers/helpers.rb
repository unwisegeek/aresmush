module AresMUSH
  module Pf2e

    def self.get_ability_score(abilities,abil_name)
      stat = abilities.abil_name
      stat[:mod_val] ? stat[:mod_val] : stat[:base_val]
    end

    def self.get_prof_level(char, target)
      sheet = char.pf2sheet
    end

    def self.get_ability_mod(score)
      mod = (score - 10) / 2
    end

    def self.get_prof_bonus(p=:untrained)
      levels = { untrained: 0, trained: 2, expert: 4, master: 6, legendary: 8 }
      p = p.to_sym
      bonus = levels[p]
    end

    def self.create_sheet(char)
      sheet = Pf2eSheet.new
      abilities = Pf2eAbilities.new

      char.pf2sheet = sheet
      sheet.char = char
      sheet.abilities = abilities
      abilities.pf2sheet = sheet

      abilities.save
      char.save
      sheet.save

      return sheet
    end

    def self.roll_dice(amount=1, sides=20)
      result = amount.to_i.times { |t| rand(1..sides.to_i) }
      total = result.sum
      return [ result, total ]
    end

    def self.can_take_feat?(char, feat)
      error = FeatValidator.req_check(char, feat)
      if error
        return false
      else
        return true
      end
    end

    def self.character_has?(array, element)
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
