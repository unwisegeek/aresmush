module AresMUSH
  class Pf2eHP < Ohm::ObjectModel
    include ObjectModel

    attribute :current, :type => DataType::Integer, :default => 0
    attribute :max_current, :type => DataType::Integer, :default => 0
    attribute :max_base, :type => DataType::Integer, :default => 0
    attribute :base_for_level, :type => DataType::Integer, :default => 0

    reference :character, "AresMUSH::Character"
  end
end
