module AresMUSH
  module Tinker
    class TinkerCmd
      include CommandHandler
      
      def handle
      
        array = [] 
          
        open_skills = 4
          
        skills_array = array.fill("open", nil, open_skills)
        
        client.emit skills_array
        
      end
      
    end
  end
end
