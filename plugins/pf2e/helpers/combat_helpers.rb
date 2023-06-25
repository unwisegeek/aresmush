module AresMUSH
  module Pf2e

    def self.is_valid_init_stat(stat)

      abilities = [ 'Strength', 'Dexterity', 'Constitution', 'Intelligence', 'Wisdom', 'Charisma' ]
      skills = Global.read_config('pf2e_skills').keys
      combat_stats = ['Perception']

      valid_init_stat = abilities + skills + combat_stats

      # Is there a unique match? Error if no match or multiple matches

      usable_init_stat = valid_init_stat.map { |s| s.match? init_stat }

      return false if usable_init_stat.size != 1

      return true 
      end



  end
end