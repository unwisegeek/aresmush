module AresMUSH
  module Pf2emagic

    def generate_blank_spell_list(obj)
      prepared_list = {}
      spells_per_day = obj.spells_per_day

      spells_per_day.each_pair do |level, count|
        list = Array.new(count, "open")

        prepared_list[level] = list
      end

      prepared_list
    end

    def get_focus_casting_stat(stype)
      Global.read_config('pf2e_magic', 'focus_casting_stat', stype)
    end

    def self.get_caster_type(charclass)
      prepared = Global.read_config('pf2e_magic', 'prepared_casters')
      spont = Global.read_config('pf2e_magic', 'spontaneous_casters')

      return 'prepared' if prepared.include? charclass
      return 'spontaneous' if spont.include? charclass
      return nil

    end

    def self.select_spell(char, charclass, level, old_spell, new_spell, common_only=false)
      # Is new_spell a valid, unique choice? 
      # Only common spells are available in cg/advancement, set last argument to true to enforce

      hash = common_only ? PF2emagic.find_common_spells : Global.read_config('pf2e_spells')
      list = hash.keys.map { |s| s.upcase }
      to_find = new_spell.upcase
      match = list.select { |s| s == to_find }

      return t('pf2emagic.no_such_spell') if match.empty?
      return t('pf2emagic.multiple_matches', :item => 'spell') if (match.size > 1)

      to_add = match.first
      deets = hash[to_add]

      # Can the class they specified cast the spell they want? 
      magic = char.magic
      charclass_trad = magic.tradition[charclass]
      caster_type = get_caster_type(charclass)
      return t('pf2emagic.cant_cast_as_class') unless (charclass_trad && caster_type)

      charclass_can_cast = deets['tradition'].include? charclass_trad[0]
      return t('pf2emagic.class_does_not_get_spell') unless charclass_can_cast

      # Which list does it go in? 
      char_list = caster_type == "prepared" ? "spellbook" : "repertoire"

      # Can they learn that level of spell? 
      # This is assumed to be true if the base level of the spell is a key in either the to_assign hash for the list type 
      # OR in the character's personal list.





    end

    def self.find_common_spells 
      Global.read_config('pf2e_spells').select { |k,v| v['traits'].include? 'common' }
    end
  end
end
