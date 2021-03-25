module AresMUSH
  module Tinker
    class TinkerCmd
      include CommandHandler
      
      def check_can_manage
        return t('dispatcher.not_allowed') if !enactor.has_permission?("tinker")
        return nil
      end
      
      def handle
      
        subject = ClassTargetFinder.find('Derecho', Character, enactor)
        if subject.found
            client.emit "Subject:" + subject
            client.emit subject.target
            client.emit subject.target.name
        else 
            client.emit "Error: " + subject.error
        end
      end

    end
  end
end
