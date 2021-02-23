module AresMUSH
  module Pf2e
    class Pf2eSkills

      def self.get_linked_attr(skill)
        skill = Global.read_config('pf2e_skills', skill)
        linked_attr = skill['key_abil']
      end


    end
  end
end
