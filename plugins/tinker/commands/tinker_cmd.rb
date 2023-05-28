module AresMUSH
  module Tinker
    class TinkerCmd
      include CommandHandler
      
      def check_can_manage
        return t('dispatcher.not_allowed') if !enactor.has_permission?("tinker")
        return nil
      end
      
      def handle
        feat_list = [ "Wary Disarmament", "Diehard", "Vibrant Display", "Adopted Ancestry" ]

        @details = Global.read_config('pf2e_feats').keep_if { |k,v| feat_list.include? k }
        
        client.emit "Feat List: #{feat_list.sort.join(", ")}"
        client.emit "Feat Details Hash: #{@details}"
        
        
      end

    end
  end
end
