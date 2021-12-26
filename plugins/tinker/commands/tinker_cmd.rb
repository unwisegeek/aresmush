module AresMUSH
  module Tinker
    class TinkerCmd
      include CommandHandler
      
      def check_can_manage
        return t('dispatcher.not_allowed') if !enactor.has_permission?("tinker")
        return nil
      end
      
      def handle
        char=Character.find_one_by_name("Testchar")
        working_boost_list = char.pf2_boosts_working
        boost_values = working_boost_list['background']
        
        option_check = boost_values.select { |val| val.is_a?(Array) }
        
        client.emit "Working Boost List - #{working_boost_list}"
        client.emit "Boost Values - #{working_boost_list['background']}"
        client.emit "Option Check - #{option_check}"
        
      end

    end
  end
end
