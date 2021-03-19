module AresMUSH
  module Tinker
    class TinkerCmd
      include CommandHandler
      
      def check_can_manage
        return t('dispatcher.not_allowed') if !enactor.has_permission?("tinker")
        return nil
      end
      
      def handle
        char = AresMUSH::Character.find_one_by_name('Landtest')
      
        return [] if abilities.empty?
        
        list = []
        abilities.each do |a,i|
          name = a.name
          score = a.mod_val ? a.mod_val : a.base_val
          list << format_ability(name, score, i)
        end
        list
      end

    end
  end
end
