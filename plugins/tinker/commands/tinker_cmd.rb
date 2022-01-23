module AresMUSH
  module Tinker
    class TinkerCmd
      include CommandHandler
      
      def check_can_manage
        return t('dispatcher.not_allowed') if !enactor.has_permission?("tinker")
        return nil
      end
      
      def handle
        char = Character.find_one_by_name("testchar")
        
        obj_list = char.skills
        
        obj_list_sorted = obj_list.to_a.sort_by { |a| a.name }
        
        skills = obj_list.map { |a| a.name }
        
        skills_sorted = obj_list_sorted.map { |a| a.name }
        
        client.emit skills
        
        client.emit skills_sorted
        
      end

    end
  end
end
