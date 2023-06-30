module AresMUSH
  module Tinker
    class TinkerCmd
      include CommandHandler
      
      def check_can_manage
        return t('dispatcher.not_allowed') if !enactor.has_permission?("tinker")
        return nil
      end
      
      def handle
      
        time = Time.now
        
        client.emit time
        client.emit time.strftime("(%k:%M)")
        client.emit time.strftime("Date of Encounter: %B %e, %Y")
        

      end

    end
  end
end
