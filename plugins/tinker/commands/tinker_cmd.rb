module AresMUSH
  module Tinker
    class TinkerCmd
      include CommandHandler
      
      def check_can_manage
        return t('dispatcher.not_allowed') if !enactor.has_permission?("tinker")
        return nil
      end
      
      def handle
      
        list = [[10.0, "Bob"], [15.0, "Amy"], [8.0, "Charlie"], [10.2, "Bad Guy"]]
        
        client.emit list.sort_by { |p| -p[0] }
      end

    end
  end
end
