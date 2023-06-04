module AresMUSH
  module Tinker
    class TinkerCmd
      include CommandHandler
      
      def check_can_manage
        return t('dispatcher.not_allowed') if !enactor.has_permission?("tinker")
        return nil
      end
      
      def handle
      
        char = Character.find_one_by_name("Testchar")
        
        required = "Society/trained"
        
        if required =~ /\//
          string = required.split("/")
          factor = string[0]
          minimum = string[1]
        end
        
        client.emit string
        client.emit factor
        client.emit minimum
      
        char_prof = Pf2e.get_prof_bonus(char, Pf2eSkills.get_skill_prof(char, factor))
        min_prof = Pf2e.get_prof_bonus(char, minimum)

        client.emit char_prof
        client.emit min_prof
        
        check = (char_prof < min_prof) ? "fail" : "pass"
        
        client.emit check
        
      end

    end
  end
end
