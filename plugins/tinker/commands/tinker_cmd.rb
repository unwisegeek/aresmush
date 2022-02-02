module AresMUSH
  module Tinker
    class TinkerCmd
      include CommandHandler
      
      def check_can_manage
        return t('dispatcher.not_allowed') if !enactor.has_permission?("tinker")
        return nil
      end
      
      def handle
          restricted = []
          
          ancestry = 'Sildanyar'
          background = 'Feybound'
          heritage = 'Dar'
        
          a_rare = Global.read_config('pf2e_ancestry', ancestry)['rare']
          b_rare = Global.read_config('pf2e_background', background)['rare']
          h_rare = Global.read_config('pf2e_heritage', heritage)['rare']
        
          restricted << "ancestry" if a_rare
          restricted << "background" if b_rare
          restricted << "heritage" if h_rare
          
          client.emit restricted.join(", ")
      end

    end
  end
end
