module AresMUSH
  module Tinker
    class TinkerCmd
      include CommandHandler
      
      def check_can_manage
        return t('dispatcher.not_allowed') if !enactor.has_permission?("tinker")
        return nil
      end
      
      def handle
        char = Character.find_one_by_name("rashmi")
          
        skill_list = Global.read_config('pf2e_skills').keys

        skill_list.each do |s|
          Pf2eSkills.create_skill_for_char(s, enactor)
        end
      end

    end
  end
end
