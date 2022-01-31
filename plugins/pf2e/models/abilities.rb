module AresMUSH
  class Pf2eAbilities < Ohm::Model
    include ObjectModel
    include FindByName

    attribute :name
    attribute :name_upcase
    attribute :shortname
    attribute :base_val, :type => DataType::Integer, :default => 10
    attribute :mod_val, :default => false
    index :name_upcase

    before_save :set_upcase_name

    def set_upcase_name
      self.name_upcase = self.name.upcase
    end

    reference :character, "AresMUSH::Character"

    ##### CLASS METHODS #####

    def self.abilmod(score=10)
      (score - 10) / 2
    end

    def self.get_score(char, ability)
      object = char.abilities.select { |a| a.name_upcase == ability.upcase }.first

      return nil if !object

      object.mod_val ? object.mod_val : object.base_val
    end

    def self.update_base_score(char,ability,mod=2)
      object = char.abilities.select { |a| a.name_upcase == ability.upcase }.first

      return nil if !object

      base = object.base_val

      if (mod.negative?)
        high_mod = -1
        mod = base <= 18 ? mod : high_mod
        new_base = base + mod
      else
        high_mod = 1
        mod = base < 18 ? mod : high_mod
        new_base = base + mod
      end

      object.update(base_val: new_base)
    end

    def self.abilities_messages(char)
      messages = []

      boosts = char.pf2_boosts_working
      a = []
      boosts.each_pair do |k,v|
        free_unassigned = v.include?("open")
        choice_not_made = v.any? { |v| v.is_a?(Array) }

        a << k if free_unassigned || choice_not_made
      end

      if !a.empty?
        messages << t('pf2e.unassigned_abilities',
          :missing => a.uniq.sort.join(", ")
        )
      end

      boosts.each do |k,v|
        messages << t('pf2e.boost_not_unique', :type => k) if v != v.uniq
      end

      scores = {}
      char.abilities.each do |a|
        k = a.name
        v = a.base_val
        scores[k] = v
      end

      bad_scores = []
      scores.each do |k, v|
        bad_scores << k if v > 18
      end

      if bad_scores.count > 0
        messages << t('pf2e.ability_too_high', :score => bad_scores.join(', '))
      end

      return messages.join if !messages.empty?
    end


  end
end
