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
        
        list = {}
        
        feats.each_pair do |k,v|
            name = k
            feat_req = v.dig('prereq', 'feat')
            
            (list[name] = feat_req) if feat_req
        end
        
        client.emit list
        
        list.each_pair do |k,v|
            client.emit "#{k}: #{v}"
        end
        
      end

    end
  end
end
