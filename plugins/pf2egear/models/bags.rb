module AresMUSH
  class PF2Bag < Ohm::Model
    include ObjectModel

    attribute :name, :default => "Bag"
    attribute :bulk, :type => DataType::Float, :default => 0
    attribute :traits, :type => DataType::Array, :default => []
    attribute :level, :type => DataType::Integer, :default => 0
    attribute :price, :type => DataType::Integer, :default => 0
    attribute :capacity, :type => DataType::Integer, :default => 0
    attribute :gear_contents, :type => DataType::Hash, :default => {}

    reference :character, "AresMUSH::Character"
    collection :weapons, "AresMUSH::PF2Weapon"
    collection :armor, "AresMUSH::PF2Armor"
    collection :shields, "AresMUSH::PF2Shields"
    collection :magicitems, "AresMUSH::PF2MagicItem"

  end
end
