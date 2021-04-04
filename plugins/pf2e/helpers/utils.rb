module AresMUSH
  module Pf2e

    def self.find_character_ability(char, type, name)
      case type.downcase
      when 'ability' then element_list = char.abilities
      when 'skill' then element_list = char.skills
      when 'lore' then element_list = char.lores
      else element_list = nil
      end

      return nil if !element_list

      element = element_list.select { |a| a.name_upcase == name.upcase }[0]
    end

    # p can be passed to this method as nil
    def self.get_prof_bonus(p="untrained")
      levels = { "untrained"=>0, "trained"=>2, "expert"=>4, "master"=>6, "legendary"=>8 }
      bonus = levels[p]
    end

    def self.get_linked_attr_mod(char, value, type=nil)
      attr_type = type.is_a?(String) ? type.downcase : type

      case attr_type
      when 'skill'
        skill_mod = Pf2eSkills.get_linked_attr(value)
        return Pf2eAbilities.get_ability_mod(Pf2eAbilities.get_ability_score(char, skill_mod))
      when 'lore'
        return Pf2eAbilities.get_ability_mod(Pf2eAbilities.get_ability_score char, 'Intelligence')
      when nil
        case value.downcase
        when 'fort', 'fortitude'
          return Pf2eAbilities.get_ability_mod(Pf2eAbilities.get_ability_score char, 'Constitution')
        when 'ref', 'reflex', 'ranged', 'finesse'
          return Pf2eAbilities.get_ability_mod(Pf2eAbilities.get_ability_score char, 'Dexterity')
        when 'will', 'perception'
          return Pf2eAbilities.get_ability_mod(Pf2eAbilities.get_ability_score char, 'Wisdom')
        when 'melee'
          return Pf2eAbilities.get_ability_mod(Pf2eAbilities.get_ability_score char, 'Strength')
        end
      end
    end

    def self.get_keyword_value(char, word)
      downcase_word = word.downcase

      # Word could be many things - figure out which
      case downcase_word
      when 'will', 'fort', 'fortitude', 'ref', 'reflex'
        Pf2eCombat.get_save_bonus(char, word)

      # This will change when I establish attack code
      when 'melee', 'ranged', 'unarmed', 'finesse' then 0

      when 'strength', 'dexterity', 'constitution', 'intelligence', 'wisdom', 'charisma'
        Pf2eAbilities.get_ability_mod Pf2eAbilities.get_ability_score(char, word)

      when 'str', 'dex', 'con', 'int', 'wis', 'cha'
        shortname = word.upcase
        obj = char.abilities.select { |a| a.shortname == shortname }
        return 0 if !obj
        Pf2eAbilities.get_ability_mod Pf2eAbilities.get_ability_score(char, obj.name)

      else
        value = 0

        roll_keywords = Global.read_config('pf2e', 'roll_keywords')
        skills = Global.read_config('pf2e_skills').keys.each { |s| s.downcase }

        if roll_keywords.has_key?(downcase_word)
          value = roll_keywords[downcase_word]
        elsif skills.member?(downcase_word)
          value = Pf2eSkills.get_skill_bonus(char, downcase_word)
        elsif downcase_word.match?(/.+\slore$/)
          value = Pf2eSkills.get_lore_bonus(char, downcase_word)
        end

        value
      end
    end

    def self.roll_dice(amount=1, sides=20)
      result = amount.to_i.times.collect { |t| rand(1..sides.to_i) }
    end

    def self.character_has?(array, element)
      array.include?(element)
    end

    def self.character_has_index?(array, element)
      if array.member?(element)
        return array.index(element)
      else
        return false
      end
    end

    def self.get_level_tier(level)
      1 + level / 5
    end

    def self.bonus_from_item(char, type)
      return nil
    end

    def self.convert_money(value, type)
      case type
      when "platinum", "pp"
        multiplier = 1000
      when "gold", "gp"
        multiplier = 100
      when "silver", "sp"
        multiplier = 10
      when "copper", "cp"
        multiplier = 1
      else
        return nil
      end

      value * multiplier
    end

    def self.parse_roll_string(target,list)
      aliases = target.pf2_roll_aliases
      roll_list = list.map { |word|
        aliases.has_key?(word) ?
        aliases[word].gsub("-", "+-").gsub("--","-").split("+")
        : word
      }.flatten

      dice_pattern = /([0-9]+)d[0-9]+/i
      find_dice = roll_list.select { |d| d =~ dice_pattern }

      roll_list.unshift('1d20') if find_dice.empty?

      result = []
      roll_list.map do |e|
        if e =~ dice_pattern
          dice = e.gsub("d"," ").split
          amount = dice[0].to_i > 0 ? dice[0].to_i : 1
          sides = dice[1].to_i
          result << Pf2e.roll_dice(amount, sides)
        elsif e.to_i == 0
          result << Pf2e.get_keyword_value(enactor, e)
        else
          result << e.to_i
        end
      end

      fmt_result = result.map do |word|
        if word.is_a? Array
          fmt_word = word.map { |w| "%xc#{w}%xn" }
          "(" + fmt_word.join(" ") + ")"
        else
          word
        end
      end

      return_hash = {}
      return_hash['list'] = roll_list
      return_hash['result'] = fmt_result
      return_hash['total'] = result.flatten.sum

      return return_hash
    end

    def self.get_degree(list,result,total,dc)
      degrees = [ "(%xrCRITICAL FAILURE%xn)",
        "(%xh%xyFAILURE%xn)",
        "(%xgSUCCESS!%xn)",
        "(%xh%xmCRITICAL SUCCESS!%xn)"
      ]
      if total - dc >= 10
        scase = 3
      elsif total >= dc
        scase = 2
      elsif total - dc <= -10
        scase = 0
      else
        scase = 1
      end

      if list[0] == '1d20'
        succ_mod = 0
        succ_mod = 1 if result[0] == 20
        succ_mod = -1 if result[0] == 1
      end

      success_case = (scase + succ_mod).clamp(0,3)
      degree = degrees[success_case]
    end

  end
end
