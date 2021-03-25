module AresMUSH
  module Tinker
    class TinkerCmd
      include CommandHandler
      
      def check_can_manage
        return t('dispatcher.not_allowed') if !enactor.has_permission?("tinker")
        return nil
      end
      
      def handle
      
        roll_list = %w{1d6 5}
        dice_pattern = /([0-9]+)d[0-9]+/i
      
        result = []
        roll_list.map do |e|
          if e =~ dice_pattern
            dice = e.gsub("d"," ").split
            amount = dice[0].to_i > 0 ? dice[0].to_i : 1
            sides = dice[1].to_i
            result << Pf2e.roll_dice(amount, sides)
          elsif e.to_i == 0
            result << Pf2e.get_keyword_value(enactor, e)
          else
            result << e.to_i
          end
        end
        
        client.emit result
    
      end

    end
  end
end
