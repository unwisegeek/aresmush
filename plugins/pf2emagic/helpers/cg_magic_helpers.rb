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

  end
end
module AresMUSH
  module Pf2emagic

    def self.select_spell(char, type, charclass, old_spell, new_spell)


    end
  end
end
