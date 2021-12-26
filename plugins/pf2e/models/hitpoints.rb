module AresMUSH
  class Pf2eHP < Ohm::Model
    include ObjectModel

    # Tracks damage and CON mod changes
    attribute :current, :type => DataType::Integer, :default => 0
    # Max accounting for CON mod change
    attribute :max_current, :type => DataType::Integer, :default => 0
    # Includes base CON mod only
    attribute :max_base, :type => DataType::Integer, :default => 0
    # Changes only at advancement, no CON mod
    attribute :base_for_level, :type => DataType::Integer, :default => 0
    # Tracks base HP for past levels, because someone will want to
    attribute :hp_per_level, :type => DataType::Hash, :default => {}

    reference :character, "AresMUSH::Character"



    ##### CLASS METHODS #####

    def self.get_hp_obj(char)
      obj = char.hp
    end

  end
end
