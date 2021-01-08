module AresMUSH
  module AltTracker
    class Player < Ohm::Model
      include ObjectModel
      attribute :email
      attribute :codeword
      attribute :banned
      attribute :mark_idle
      collection :characters, "AresMUSH::Character"
    end
  end

  class Character
    reference :player, "AresMUSH::AltTracker::Player"
  end
end
