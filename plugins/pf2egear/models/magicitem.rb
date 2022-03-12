module AresMUSH
  class PF2MagicItem < Ohm::Model
    include ObjectModel

    attribute :name, :default => "Magic Item"
    attribute :bulk, :type => DataType::Float, :default => 0
    attribute :traits, :type => DataType::Array, :default => []
    attribute :level, :type => DataType::Integer, :default => 1
    attribute :price, :type => DataType::Integer, :default => 0
    attribute :slot, :default => ""
    attribute :use, :type => DataType::Hash, :default => {}
    attribute :equipped, :type => DataType::Boolean
    attribute :invested, :type => DataType::Boolean

    reference :character, "AresMUSH::Character"
    reference :bag, "AresMUSH::PF2Bag"

  end
end
