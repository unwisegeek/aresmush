module AresMUSH
  module Tinker
    class TinkerCmd
      include CommandHandler
      
      def check_can_manage
        return t('dispatcher.not_allowed') if !enactor.has_permission?("tinker")
        return nil
      end
      
      def handle
        t = Time.now
        
        sides = [ 2, 3, 4, 6, 8, 10, 12, 20, 30, 100, 1000 ].sample
        amount = rand(1..50)

        die_roll = Pf2e.roll_dice(amount, sides).sum
        
        value = t.to_i.odd? ? die_roll : -die_roll
        
        client.emit value
        
      end

    end
  end
end
