module AresMUSH
  class PF2Gear < Ohm::Model
    include ObjectModel

    attribute :name
    attribute :bulk, :type => DataType::Float, :default => 0
    attribute :traits, :type => DataType::Array, :default => []
    attribute :level, :type => DataType::Integer, :default => 0
    attribute :price, :type => DataType::Integer, :default => 0
    attribute :quantity, :type => DataType::Integer, :default => 1
    attribute :use, :type => DataType::Hash, :default => {}

    reference :character, "AresMUSH::Character"
    reference :bag, "AresMUSH::PF2Bag"

  end
end
