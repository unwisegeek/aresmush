module AresMUSH
  class Pf2eCombat < Ohm::Model
    include ObjectModel

    attribute :fortitude, :default => 'untrained'
    attribute :reflex, :default => 'untrained'
    attribute :will, :default => 'untrained'

    attribute :saves, :type => DataType::Hash, :default => { 'fortitude' => 'untrained', 'reflex' => 'untrained', 'will' => 'untrained' }

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
    attribute :wp_deity
    attribute :wp_other, :type => DataType::Hash, :default => {}

    reference :character, "AresMUSH::Character"


    ##### CLASS METHODS #####

    def self.get_save_from_char(char,save)
      combat = char.combat

      return 'untrained' if !char.combat

      save_list = combat.saves
      prof = save_list[save]
    end

    def self.get_create_combat_obj(char)
      obj = char.combat

      return obj if obj

      obj = Pf2eCombat.create(character: char)
      char.update(combat: obj)

      return obj
    end

    def self.update_combat_stats(char, info)
      combat = get_create_combat_obj(char)

      info.each_pair do |key, value|
        combat.update("#{key}": value)
      end

      # This is a kludge, fix this method later

      save_list = info['saves']
      saves = {}
      save_list.each_pair { |k,v| saves[k] = v }

      combat.update(saves: saves)

      return combat
    end

    def self.get_save_bonus(char, save)
      prof_bonus = Pf2e.get_prof_bonus(char, get_save_from_char(char, save))

      mod = Pf2e.get_linked_attr_mod(char, save)
      mod = 0 if !mod

      item = Pf2e.bonus_from_item(char, save)
      item_bonus = item ? item : 0

      prof_bonus + mod + item_bonus
    end

    def self.get_class_dc(char)
      combat_stats = char.combat

      return 0 if !combat_stats

      prof_bonus = Pf2e.get_prof_bonus(char, combat_stats.class_dc)

      key_ability = combat_stats.key_abil ? combat_stats.key_abil : "Strength"
      abil_mod = Pf2eAbilities.abilmod(Pf2eAbilities.get_score(char, key_ability))

      item = Pf2e.bonus_from_item(@char, 'class_dc')
      item_bonus = item ? item : 0

      10 + prof_bonus + abil_mod + item_bonus
    end

    def self.get_perception(char)
      abil_mod = Pf2e.get_linked_attr_mod(char, 'perception')
      combat_stats = char.combat

      return abil_mod if !combat_stats

      prof_bonus = Pf2e.get_prof_bonus(char, combat_stats.perception)

      item = Pf2e.bonus_from_item(@char, 'perception')
      item_bonus = item ? item : 0

      abil_mod + prof_bonus + item_bonus
    end

  end
end
