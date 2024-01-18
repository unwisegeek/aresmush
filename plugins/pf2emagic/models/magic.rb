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
          # Structure: { charclass => {"cantrip" => 5, 1 => 3, 2 => 1} }
          spells_per_day = magic.spells_per_day
          spd_for_class = spells_per_day[charclass] ? spells_per_day[charclass] : {}

          value.each_pair do |level, num|
            spd_for_class[level] = num
          end

          spells_per_day[charclass] = spd_for_class

          magic.update(spells_per_day: spells_per_day)
        when "focus_pool"
          pool = magic.focus_pool
          add = value

          new_max_pool = (pool["max"] + add).clamp(1,3)
          pool["max"] = new_max_pool
          magic.focus_pool = pool
        when "repertoire"
          # Spells need to be chosen, redirect to to_assign

          to_assign = char.pf2_to_assign

          assignment_list = {}
          value.each_pair do |level, num|
            ary = Array.new(num, "open")
            assignment_list[level] = ary
          end

          to_assign["repertoire spells"] = assignment_list

          char.update(pf2_to_assign: to_assign)
        when "focus_spell"
          # focus spell structure: { "devotion" => [spell, spell, spell], "revelation" => [spell] }

          focus_spells = magic.focus_spells

          value.each_pair do |fstype, spell_list|
            fs_by_type = focus_spells[stype] ? focus_spells[stype] : []
            fs_by_type = (fs_by_type + spell_list).uniq
            focus_spells[fstype] = fs_by_type
          end

          magic.update(focus_spells: focus_spells)
        when "focus_cantrip"
            # Structure identical to focus_spells, kept separate because they are cast differently.

            focus_cantrips = magic.focus_cantrips

            value.each_pair do |fstype, spell_list|
              fs_by_type = focus_cantrips[stype] ? focus_cantrips[stype] : []
              fs_by_type = (fs_by_type + spell_list).uniq
              focus_cantrips[fstype] = fs_by_type
            end

            magic.update(focus_cantrips: focus_cantrips)
        when "spellbook"
            # Spells need to be chosen, redirect to to_assign

            to_assign = char.pf2_to_assign

            assignment_list = {}
            value.each_pair do |level, num|
              ary = Array.new(num, "open")
              assignment_list[level] = ary
            end

            to_assign["spellbook spells"] = assignment_list

            char.update(pf2_to_assign: to_assign)
        when "addspell"
          # Addspell means to add a specific spell to the spellbook. Adding spells to be chosen
          # should be the "spellbook" key.



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
