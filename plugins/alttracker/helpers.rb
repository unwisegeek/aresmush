module AresMUSH
  module AltTracker

    def self.find_player_by_email(email, char)
      result = ClassTargetFinder.find(email, Player, char)
        if result.found?
          player = result.target
        else
          player = nil
        end
      return player
    end

    def self.find_alts_by_email(email, char)
      player = self.find_player_by_email(email, char)
      return nil unless player
      alts = player.characters.map { |c| c.name }
    end

    def self.get_altlist_by_name(name)
      char = Character.find_one_by_name(name)
      return false unless char.player
      alts = char.player.characters.map { |c| c.name }.sort
    end

    def self.get_altlist_by_object(player)
      alts = player.characters.map { |c| c.name }.sort
    end

    def self.delete_player(player)
      player.delete
    end

  end
end
