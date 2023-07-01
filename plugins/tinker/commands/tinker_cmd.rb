module AresMUSH
  module Tinker
    class TinkerCmd
      include CommandHandler
      
      def check_can_manage
        return t('dispatcher.not_allowed') if !enactor.has_permission?("tinker")
        return nil
      end
      
      def handle
      
        targets = [ "Amy", "Bob", "David" ]
      
        participants = [[10.0, "Bob"], [15.0, "Amy"], [8.0, "Charlie"], [10.2, "Bad Guy"]].collect { |p| p[1] }
        
        targets_in_encounter = targets.all? { |t| participants.include? t }
        
        client.emit targets_in_encounter
        
        client.emit participants.join(",")
        
      end

    end
  end
end
