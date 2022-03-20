module AresMUSH
  class PF2Bag < Ohm::Model
    include ObjectModel

    attribute :name, :default => "Bag"
    attribute :bulk, :type => DataType::Float, :default => 0
    attribute :bulk_bonus, :type => DataType::Float, :default => 0
    attribute :traits, :type => DataType::Array, :default => []
    attribute :level, :type => DataType::Integer, :default => 0
    attribute :price, :type => DataType::Integer, :default => 0
    attribute :capacity, :type => DataType::Integer, :default => 0
    attribute :gear_contents, :type => DataType::Hash, :default => {}

    reference :character, "AresMUSH::Character"
    collection :pf2weapon, "AresMUSH::PF2Weapon", :weapons
    collection :pf2armor, "AresMUSH::PF2Armor", :armor
    collection :pf2shield, "AresMUSH::PF2Shields", :shields
    collection :pf2magicitem, "AresMUSH::PF2MagicItem", :magicitems

  end
end
