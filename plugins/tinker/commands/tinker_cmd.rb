module AresMUSH
  module Tinker
    class TinkerCmd
      include CommandHandler
      
      def check_can_manage
        return t('dispatcher.not_allowed') if !enactor.has_permission?("tinker")
        return nil
      end
      
      def handle
        char = Character.find_one_by_name("Testchar")
        
        feat_list = char.pf2_feats.values.flatten
        
        required = [ "Intimidating Glare" ]
        
        eval = required.all? { |f| feat_list.include? f }
        
        client.emit "Tinker check returns #{eval}."
        
        
      end

    end
  end
end
