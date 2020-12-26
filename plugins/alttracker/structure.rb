module AresMUSH
  module AltTracker
    class Player < Ohm::Model
      include ObjectModel
      attribute :email
      attribute :codeword
      attribute :banned
      collection :characters, "AresMUSH::Character"
    end

  class Character
    reference :player, "AresMUSH::AltTracker::Player"
  end
end
