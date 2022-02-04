module AresMUSH
  module Tinker
    class TinkerCmd
      include CommandHandler
      
      def check_can_manage
        return t('dispatcher.not_allowed') if !enactor.has_permission?("tinker")
        return nil
      end
      
      def handle
        char = Character.find_one_by_name("Karasu")
          
        base_info = char.pf2_base_info
          
        subclass_option = base_info['specialize_info']
        charclass = base_info['charclass']
        subclass = base_info['specialize']
        
        subclass_info = Global.read_config('pf2e_specialty', charclass, subclass)
          
        subclass_option_info = subclass_option.blank? ?
                               nil :
                               subclass_info['choose']['options'][subclass_option]
                               
        subclassopt_features_info = subclass_option_info ? subclass_option_info['chargen'] : {}  
        
        subclassopt_skills = subclassopt_features_info['skills']
        
        client.emit base_info
        client.emit subclass_option
        client.emit subclass_option_info
        client.emit subclassopt_features_info
        client.emit subclassopt_skills
        
      end

    end
  end
end
