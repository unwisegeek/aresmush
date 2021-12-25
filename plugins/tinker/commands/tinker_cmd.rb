module AresMUSH
  module Tinker
    class TinkerCmd
      include CommandHandler
      
      def handle
      
        char = Character.find_one_by_name("Testchar")
      
        boosts = char.pf2_boosts_working
        
        scores = {}
        char.abilities.each do |a|
            k = a.name
            v = a.base_val
            scores[k] = v
        end
        
        score_chk = boosts.values.flatten
        
        client.emit "Char: #{char}"
        client.emit "Boosts: #{boosts}"
        client.emit "Scores: #{scores}"
        client.emit "Score-chk: #{score_chk}"
        
      end
      
    end
  end
end
