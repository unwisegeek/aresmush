module AresMUSH
  class Pf2eSkills < Ohm::Model
    include ObjectModel
    include FindByName

    attribute :name
    attribute :name_upcase
    attribute :prof_level
    attribute :cg_skill, :type => DataType::Boolean
    index :name_upcase

    before_save :set_upcase_name

    def set_upcase_name
      self.name_upcase = self.name.upcase
    end

    reference :character, "AresMUSH::Character"

    ##### CLASS METHODS #####

    def self.get_linked_attr(name)
      skill = Global.read_config('pf2e_skills', name)
      linked_attr = skill['key_abil']
    end

    def self.find_skill(name, char)
      skill = char.skills.find { |s| s.name_upcase == name.upcase }
    end

    def self.get_skill_bonus(char, name)
      skill = find_skill(name, char)
      linked_attr = get_linked_attr(name)
      abonus = Pf2eAbilities.get_ability_mod(
        Pf2eAbilities.get_ability_score(char, linked_attr)
      )
      pbonus = skill ? Pf2e.get_prof_bonus(skill.prof_level) : 0

      abonus + pbonus
    end

  end
end
