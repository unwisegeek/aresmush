module AresMUSH
  module AltTracker

    def self.find_player_by_email(email)
      player = Player.all.to_a.find { |p| p.email == email }
      return nil unless player
      return player
    end

    def self.find_alts_by_email(email)
      player = self.find_player_by_email(email)
      return nil unless player
      alts = player.characters.map { |c| c.name }
    end

    def self.find_alts_by_name(name)
      char = Character.find_one_by_name(name)
      alts = char&.player.characters.map { |c| c.name }
    end

  end
end
