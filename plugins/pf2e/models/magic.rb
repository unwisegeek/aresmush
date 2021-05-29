module AresMUSH
  class Pf2eMagic < Ohm::Model
    include ObjectModel

    attribute :tradition, :type => DataType::Hash, :default => {}
    attribute :spell_abil, :type => DataType::Hash, :default => {}
    attribute :spell_prof, :default => "untrained"
    attribute :focus_spells, :type => DataType::Hash, :default => {}
    attribute :focus_pool, :type => DataType::Hash, :default => { "max"=>0, "current"=>0 }
    attribute :innate_spells, :type => DataType::Hash, :default => {}
    attribute :spells_today, :type => DataType::Hash, :default => {}
    attribute :spells_prepared, :type => DataType::Hash, :default => {}
    attribute :spellbook, :type => DataType::Hash, :default => {}
    attribute :spells_known, :type => DataType::Hash, :default => {}
    attribute :revelation_locked, :type => DataType::Boolean
    attribute :max_spell_level, :type => DataType::Integer, :default => 0

    reference :character, "AresMUSH::Character"


    ##### CLASS METHODS #####

    def self.get_magic_obj(char)
      obj = char.magic
    end

    def self.get_create_magic_obj(char)
      obj = char.magic

      return obj if obj

      obj = Pf2eMagic.create(character: char)
      char.magic = obj

      return obj
    end

  end
end
