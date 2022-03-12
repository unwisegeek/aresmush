module AresMUSH
  class PF2Weapon < Ohm::Model
    include ObjectModel

    attribute :name, :default => "Weapon"
    attribute :bulk, :type => DataType::Float, :default => 0
    attribute :traits, :type => DataType::Array, :default => []
    attribute :level, :type => DataType::Integer, :default => 0
    attribute :price, :type => DataType::Integer, :default => 0

    attribute :talisman, :type => DataType::Array, :default => []
    attribute :wp_damage, :default => "0"
    attribute :wp_damage_2h, :default => "0"
    attribute :wp_damage_type, :type => DataType::String, :default => "B"
    attribute :wp_type, :default => ""
    attribute :category, :default => ""
    attribute :range, :type => DataType::Integer, :default => 0
    attribute :reload, :type => DataType::Integer, :default => 0
    attribute :hands, :type => DataType::Integer, :default => 1
    attribute :group, :type => DataType::String, :default => ""
    attribute :runes, :type => DataType::Hash, :default => { 'fundamental' => [], 'property' => [] }
    attribute :equipped, :type => DataType::Boolean
    attribute :use, :type => DataType::Hash, :default => {}
    attribute :magic, :type => DataType::Hash, :default => {}

    reference :character, "AresMUSH::Character"
    reference :shield, "AresMUSH::PF2Shield"
    reference :bag, "AresMUSH::PF2Bag"

  end
end
