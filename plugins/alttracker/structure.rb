module AresMUSH
  module AltTracker
    class Player < Ohm::Model
      include ObjectModel
      attribute :email
      attribute :codeword
      attribute :banned
      attribute :mark_idle
      collection :characters, "AresMUSH::Character"

      before_delete :unlink_alts

      def self.unlink_alts
        self.characters.each { |c|
          c.update(player, nil)
        }
      end
      
    end
  end

  class Character
    reference :player, "AresMUSH::AltTracker::Player"
  end
end
