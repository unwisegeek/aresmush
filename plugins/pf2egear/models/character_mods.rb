module AresMUSH
  class Character

    attribute :pf2_money, :type => DataType::Integer, :default => 1500
    attribute :pf2_gear, :type => DataType::Hash, :default => {}


    collection :weapons, "AresMUSH::PF2Weapon"
    collection :armor, "AresMUSH::PF2Armor"
    collection :bags, "AresMUSH::PF2Bag"
    collection :shields, "AresMUSH::PF2Shield"
    collection :magic_items, "AresMUSH::PF2MagicItem"
    
  end
end
