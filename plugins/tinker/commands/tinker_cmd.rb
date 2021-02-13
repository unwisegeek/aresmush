module AresMUSH
  module Tinker
    class TinkerCmd
      include CommandHandler
      
      def check_can_manage
        return t('dispatcher.not_allowed') if !enactor.has_permission?("tinker")
        return nil
      end
      
      def handle
        list = "Not an array"
        test = list.is_a?(Array) ? list.join(" and ") : list
        
        client.emit  test
      end

    end
  end
end
