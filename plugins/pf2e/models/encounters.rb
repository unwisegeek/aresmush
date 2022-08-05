module AresMUSH
  class PF2Encounter < Ohm::Model
    include ObjectModel

    attribute :name
    attribute :participants, :type => DataType::Hash, :default => {}
    attribute :organizer
    attribute :is_active, :type => DataType::Boolean, :default => true
    attribute :round, :type => DataType::Integer, :default => 1
    attribute :current

    set :characters, "AresMUSH::Character"
    reference :scene, "AresMUSH::Scene"




  end
end
