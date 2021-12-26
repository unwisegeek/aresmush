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

    def self.get_score(char, stat)
      object = ClassTargetFinder.find(stat,Pf2eAbilities,char)
      if object.found?
        score = object.target.mod_val ? object.target.mod_val : object.target.base_val
      else
        score = 10
      end

      score
    end

    def self.update_base_score(char,ability,mod=2)
      object = ClassTargetFinder.find(ability,Pf2eAbilities,char)
      if object.found?
        object = object.target
        base = object.base_val
      else
        return nil
      end

      mod = base < 18 ? mod : 1
      new_base = base + mod

      object.update(base_val: new_base)
    end

    def self.abilities_messages(char)
      messages = []

      to_assign = char.pf2_to_assign

      boost_list = {}
      to_assign.each_pair do |k,v|
        boost_list[k] = v if k.match?("boost")
      end
      a = []
      boost_list.each_pair do |k,v|
        free_unassigned = v.include?("open")
        choice_not_made = v.any? { |v| v.is_a?(Array) }

        a << k if free_unassigned || choice_not_made

        a << k if boost_list['classboost'] && boost_list['classboost'].is_a?(Array)
      end

      if !a.empty?
        messages << t('pf2e.unassigned_abilities',
          :missing => a.uniq.sort.join(", ")
        )
      end

      return messages.join if !messages.empty?

      boosts = char.pf2_boosts_working
      boosts.each do |k,v|
        messages << t('pf2e.boost_not_unique', :type => k) if v != v.uniq
      end

      scores = {}
      char.abilities.each do |a|
        k = a.name
        v = a.base_val
        scores[k] = v
      end

      #score_chk = boosts.values.flatten
      #score_chk.each do |boost|
      #  k = boost.capitalize
      #  v = scores[k]
      #  mod = v >= 18 ? 1 : 2
      #  scores[k] = v + mod
      #end

      bad_scores = []
      scores.each do |k, v|
        bad_scores << k if v > 18
      end

      if bad_scores.count > 0
        messages << t('pf2e.ability_too_high', :score => bad_scores.join(', '))
      end
    end


  end
end
