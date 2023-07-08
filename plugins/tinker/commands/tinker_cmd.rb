module AresMUSH
  module Tinker
    class TinkerCmd
      include CommandHandler
      
      def check_can_manage
        return t('dispatcher.not_allowed') if !enactor.has_permission?("tinker")
        return nil
      end
      
      def handle
      
        arg_raw = "Test=6"
        
        args = trimmed_list_arg(arg_raw, "=")
        
        args.unshift(nil) unless args[2]
        
        client.emit args
        
      end

    end
  end
end
