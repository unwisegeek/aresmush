module AresMUSH
  module Tinker
    class TinkerCmd
      include CommandHandler
      
      def check_can_manage
        return t('dispatcher.not_allowed') if !enactor.has_permission?("tinker")
        return nil
      end
      
      def handle
        char = Character.find_one_by_name("Landtest")
        
        if !char
            client.emit "Character not found."
        else
            char.pf2sheet.abilities.each do |k,v|
            client.emit k.to_s
            client.emit v
            end
        end

      end

    end
  end
end
