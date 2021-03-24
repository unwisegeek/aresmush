module AresMUSH
  class Pf2eCombat < Ohm::Model
    include ObjectModel

    attribute :fortitude, :default => 'untrained'
    attribute :reflex, :default => 'untrained'
    attribute :will, :default => 'untrained'

    attribute :perception, :default => 'untrained'
    attribute :class_dc, :default => 'untrained'
    attribute :key_abil

    attribute :armor_unarmored, :default => 'untrained'
    attribute :armor_light, :default => 'untrained'
    attribute :armor_medium, :default => 'untrained'
    attribute :armor_heavy, :default => 'untrained'

    attribute :wp_unarmed, :default => 'untrained'
    attribute :wp_simple, :default => 'untrained'
    attribute :wp_martial, :default => 'untrained'
    attribute :wp_advanced, :default => 'untrained'
    attribute :wp_rage
    attribute :wp_other, :type => DataType::Hash, :default => {}

    reference :character, "AresMUSH::Character"


    ##### CLASS METHODS #####

    def self.get_save_from_char(char,save)
      combat = char.combat

      return 'untrained' if !char.combat

      case save.downcase
      when 'fort', 'fortitude'
        return combat.fortitude
      when 'ref', 'reflex'
        return combat.reflex
      when 'will'
        return combat.will
      else
        'untrained'
      end
    end

    def self.get_save_bonus(char, save)
      prof_bonus = Pf2e.get_prof_bonus(get_save_from_char(char, save))

      mod = Pf2e.get_linked_attr_mod(char, save)
      mod = 0 if !mod

      item = Pf2e.bonus_from_item(char, save)
      item_bonus = item ? item : 0

      prof_bonus + mod + item_bonus
    end

    def self.get_class_dc(char)
      combat_stats = char.combat

      return 0 if !combat_stats

      prof_bonus = Pf2e.get_prof_bonus(combat_stats.class_dc)
      abil_mod = Pf2eAbilities.get_ability_mod(Pf2eAbilities.get_ability_score combat_stats.key_abil)

      item = Pf2e.bonus_from_item(@char, 'class_dc')
      item_bonus = item ? item : 0

      10 + prof_bonus + abil_mod + item_bonus
    end

    def get_perception(char)
      abil_mod = Pf2e.get_linked_attr_mod(char, 'perception')
      combat_stats = char.combat

      return abil_mod if !combat_stats

      prof_bonus = Pf2e.get_prof_bonus(combat_stats.perception)

      item = Pf2e.bonus_from_item(@char, 'perception')
      item_bonus = item ? item : 0

      abil_mod + prof_bonus + item_bonus
    end

  end
end
