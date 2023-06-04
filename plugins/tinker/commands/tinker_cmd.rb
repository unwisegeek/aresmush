module AresMUSH
  module Tinker
    class TinkerCmd
      include CommandHandler
      
      def check_can_manage
        return t('dispatcher.not_allowed') if !enactor.has_permission?("tinker")
        return nil
      end
      
      def handle
      
        feats = Global.read_config('pf2e_feats')

        list = []

        feats.each_pair do |name, details|

            list << name unless details['feat_type']

        end
        
        client.emit list.sort.join(", ")
        
      end

    end
  end
end
