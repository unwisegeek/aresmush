module AresMUSH
  module Tinker
    class TinkerCmd
      include CommandHandler
      
      def check_can_manage
        return t('dispatcher.not_allowed') if !enactor.has_permission?("tinker")
        return nil
      end
      
      def handle
        money = 1234567
        
        cp = money % 10
        sp = (money/10) % 10
        gp = (money/100) % 10
        pp = (money/1000)
        
        client.emit "#{pp} pp, #{gp} gp, #{sp} sp, #{cp} cp"
      end

    end
  end
end
