module AresMUSH
  class PF2Magic < Ohm::Model
    include ObjectModel

    attribute :focus_cantrips, :type => DataType::Hash, :default => {}
    attribute :focus_spells, :type => DataType::Hash, :default => {}
    attribute :focus_pool, :type => DataType::Hash, :default => { "max"=>0, "current"=>0 }
    attribute :innate_spells, :type => DataType::Hash, :default => {}
    attribute :revelation_locked, :type => DataType::Boolean
    attribute :signature_spells, :type => DataType::Hash, :default => {}
    attribute :repertoire, :type => DataType::Hash, :default => {}
    attribute :spell_abil, :type => DataType::Hash, :default => {}
    attribute :spellbook, :type => DataType::Hash, :default => {}
    attribute :spells_per_day, :type => DataType::Hash, :default => {}
    attribute :spells_prepared, :type => DataType::Hash, :default => {}
    attribute :spells_today, :type => DataType::Hash, :default => {}
    attribute :tradition, :type => DataType::Hash, :default => {}
    attribute :prepared_lists, :type => DataType::Hash, :default => {}

    reference :character, "AresMUSH::Character"


    ##### CLASS METHODS #####

    def self.get_magic_obj(char)
      obj = char.magic
    end

    def self.get_create_magic_obj(char)
      obj = char.magic

      return obj if obj

      obj = PF2Magic.create(character: char)
      char.update(magic: obj)

      return obj
    end

    def self.update_magic_for_class(char, charclass, info, client)
      magic = get_create_magic_obj(char)

      info.each_pair do |key, value|
        case key
        when "spell_abil"
          magic.spell_abil[charclass] = value
        when "tradition"
          # magic.tradition structure: { charclass => [ trad, prof ] }
          value.each_pair do |trad, prof|
            magic.tradition[charclass] = [ trad, prof ]
          end
        when "spells_per_day"
          value.each_pair do |level, num|
            magic.spells_per_day[level] = num
          end
        when "focus_pool"
          pool = magic.focus_pool
          add = value

          new_max_pool = (pool["max"] + add).clamp(1,3)
          pool["max"] = new_max_pool
          magic.focus_pool = pool
        when "repertoire"
        when "focus_spell"
        when "focus_cantrip"
        when "addspell"
          # Addspell means add a spell to the spellbook.
        when "signature_spells"
        else
          client.emit_ooc "Unknown key #{key} in update_magic_for_class. Please inform staff."
        end
      end

      magic.save

      return magic
    end

    def self.get_spell_dc(char, charclass, is_focus=false)

      # is_focus should be the focus spell type if given.

      magic = char.magic
      return nil unless magic

      spell_abil = is_focus ? get_focus_casting_stat(is_focus) : magic.spell_abil[charclass]

      prof = magic.tradition[charclass][1]
      prof_bonus = Pf2e.get_prof_bonus(char, prof)

      abil_mod = Pf2eAbilities.abilmod(
        Pf2eAbilities.get_score char, spell_abil
      )

      10 + abil_mod + prof_bonus
    end

    def self.get_spell_attack_bonus(char, charclass, is_focus=false)

      # is_focus should be the focus spell type if given.

      magic = char.magic
      return nil unless magic

      spell_abil = is_focus ? get_focus_casting_stat(is_focus) : magic.spell_abil[charclass]

      prof = magic.tradition[charclass][1]
      prof_bonus = Pf2e.get_prof_bonus(char, prof)

      abil_mod = Pf2eAbilities.abilmod(
        Pf2eAbilities.get_score char, spell_abil
      )

      abil_mod + prof_bonus
    end

  end
end
