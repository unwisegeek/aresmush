module AresMUSH
  module Tinker
    class TinkerCmd
      include CommandHandler
      
      def check_can_manage
        return t('dispatcher.not_allowed') if !enactor.has_permission?("tinker")
        return nil
      end
      
      def handle
        char = "Landslide"
      
        subject = ClassTargetFinder.find(char, Character, enactor)
        if subject.found
            client.emit subject.target
        else 
            whoops = subject.error ? subject.error : 'Error is nil.'
            client.emit whoops
        end
      end
    end
  end
end
