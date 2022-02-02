module AresMUSH
  class Pf2eHP < Ohm::Model
    include ObjectModel


    attribute :ancestry_hp, :type => DataType::Integer, :default => 0
    attribute :charclass_hp, :type => DataType::Integer, :default => 0
    attribute :damage, :type => DataType::Integer, :default => 0
    attribute :temp_max, :type => DataType::Integer, :default => 0
    attribute :temp_current, :type => DataType::Integer, :default => 0


    reference :character, "AresMUSH::Character"



    ##### CLASS METHODS #####

    def self.get_hp_obj(char)
      obj = char.hp
    end

    def self.max_hp(char)
      hp = get_hp_obj(char)
      con_mod = Pf2eAbilities.abilmod(Pf2eAbilities.get_score(char, "Constitution"))
      ancestry_hp = hp.ancestry_hp
      charclass_hp = hp.charclass_hp
      level = char.pf2_level
      # drain_value = Pf2e.get_condition_value(char, 'Drained')
      # For right now, until I do conditions, it's just 0
      drain_value = 0

      max_hp = (charclass_hp + con_mod - drain_value) * level + ancestry_hp
    end

    def self.current_hp(char)
      hp = char.hp
      max_hp = max_hp(char)
      damage = hp.damage

      cur_hp = max_hp - damage
    end

  end
end
