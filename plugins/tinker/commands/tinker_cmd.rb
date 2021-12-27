module AresMUSH
  module Tinker
    class TinkerCmd
      include CommandHandler
      
      def check_can_manage
        return t('dispatcher.not_allowed') if !enactor.has_permission?("tinker")
        return nil
      end
      
      def handle
        ary = ["1","2","3"]
        nested_array = Array.new(1,ary)
        
        client.emit "#{nested_array}"
        
      end

    end
  end
end
