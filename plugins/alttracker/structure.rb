module AresMUSH
  class Player < Ohm::Model
    include ObjectModel
    include FindByName

    attribute :email
    attribute :name
    attribute :name_upcase
    attribute :codeword
    attribute :banned
    attribute :mark_idle
    collection :characters, "AresMUSH::Character"

    index :name_upcase

    before_save :set_upcase_name

    before_delete :unlink_alts

    def self.unlink_alts
      self.characters.each do |c|
        c.update(player, nil)
      end
    end

    def set_upcase_name
      self.name_upcase = self.name.upcase
    end

  end

  class Character
    reference :player, "AresMUSH::Player"
  end
end
