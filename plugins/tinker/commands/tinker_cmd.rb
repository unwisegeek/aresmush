module AresMUSH
  module Tinker
    class TinkerCmd
      include CommandHandler
      
      def check_can_manage
        return t('dispatcher.not_allowed') if !enactor.has_permission?("tinker")
        return nil
      end
      
      def handle
      
        initlist = [[10.0, "Bob"], [9.2, "Bad Guy"], [8.0, "Charlie"], [6.0, "Amy"]]
        
        this_init = 2
        
        next_init = (this_init + 1) % initlist.size
        
        next_name = initlist[next_init][1]
        this_name = initlist[this_init][1]
        
        round_text = "Initiative advances!"
        
        message = t('pf2e.advance_init', 
          :current => this_name, 
          :next => next_name, 
          :init => initlist[this_init][0].to_i,
          :round => round_text
        )
        
        client.emit message
        
      end

    end
  end
end
