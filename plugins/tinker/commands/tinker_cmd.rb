module AresMUSH
  module Tinker
    class TinkerCmd
      include CommandHandler
      
      def check_can_manage
        return t('dispatcher.not_allowed') if !enactor.has_permission?("tinker")
        return nil
      end
      
      def handle
        target = "Landtest2"
        char = ClassTargetFinder.find(target, Character, enactor)
        base_info = char.pf2_base_info
        if base_info
            base_info.each do |k,v|
                client.emit "#{k.to_s.capitalize} = #{v}"
            end
        else
            client.emit "Base info not grabbed." 
        end
            
      end

    end
  end
end
