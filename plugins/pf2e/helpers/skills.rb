module AresMUSH
  module Pf2e
    class Pf2eSkills

      def self.get_linked_attr(name)
        skill = Global.read_config('pf2e_skills', name)
        linked_attr = skill['key_abil']
      end

      def self.find_skill(name, char)
        skill = char.skills.find { |s| s.name_upcase == name.upcase }
      end


    end
  end
end
