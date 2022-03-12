module AresMUSH
  module Tinker
    class TinkerCmd
      include CommandHandler
      
      def check_can_manage
        return t('dispatcher.not_allowed') if !enactor.has_permission?("tinker")
        return nil
      end
      
      def handle
        array = %w{untrained trained expert untrained expert trained}
      
        profs = %w{untrained trained expert master legendary}

        sorted_array = array.sort{ |a,b| profs.index(a) <=> profs.index(b) }

        best_prof = sorted_array.pop
        
        client.emit sorted_array
        client.emit best_prof
      end

    end
  end
end
