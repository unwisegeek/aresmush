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
        type = 'cHaRcLaSs'
      
        options = Pf2e.get_feat_options(char, type)
        
        list = []
        
        options.each do |name|
          prereqs = Global.read_config('pf2e_feats', name, 'prereq')
          list << name if Pf2e.meets_prereqs?(char, prereqs)
        end
        
        client.emit "List: #{list.sort}"
        
      end

    end
  end
end
