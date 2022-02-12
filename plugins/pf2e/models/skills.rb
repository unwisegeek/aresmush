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
      skill = @char.skills.select { |s| s.name_upcase == name.upcase }.first
    end

    def self.get_skill_bonus(char, name)
      skill = find_skill(name, char)
      linked_attr = get_linked_attr(name)
      abonus = Pf2eAbilities.abilmod(
        Pf2eAbilities.get_score(char, linked_attr)
      )
      pbonus = skill ? Pf2e.get_prof_bonus(char, skill.prof_level) : 0

      abonus + pbonus
    end

    def self.get_skill_prof(char, name)
      skill = find_skill(name, char)
      prof = skill.prof_level
    end

    def self.create_skill_for_char(name, char)
      Pf2eSkills.create(name: name, prof_level: 'untrained', character: char)
    end

    def self.update_skill_for_char(name, char, prof, cg_skill=false)
      skill = find_skill(name, char)

      return nil if !skill

      skill.update(prof_level: prof)
      skill.update(cg_skill: true) if cg_skill
    end

  end
end
