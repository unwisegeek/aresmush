module AresMUSH
  class Character
    attribute :pf2_baseinfo_locked, :type => DataType::Boolean
    attribute :pf2_reset. :type => DataType::Boolean

    attribute :pf2_base_info, :type => DataType::Hash, :default => { 'ancestry'=>"", 'heritage'=>"", 'background'=>"", 'charclass'=>"", "specialize"=>"" }
    attribute :pf2_level, :type => DataType::Integer, :default => 1
    attribute :pf2_xp, :type => DataType::Integer, :default => 0
    attribute :pf2_conditions, :type => DataType::Hash, :default => {}
    attribute :pf2_features, :type => DataType::Array, :default => []
    attribute :pf2_traits, :type => DataType::Array, :default => []
    attribute :pf2_feats, :type => DataType::Array, :default => []
    attribute :pf2_faith, :type => DataType::Hash, :default => { 'faith'=>"", 'deity'=>"", 'alignment'=>"" }
    attribute :pf2_special, :type => DataType::Array, :default => []
    attribute :pf2_boosts, :type => DataType::Hash, :default => { 'free'=>[], 'ancestry'=>[], 'background'=>[], 'charclass'=>[], 'unspent'=>4 }
    attribute :pf2_saves, :type =>DataType::Hash, :default => { 'Fortitude'=>'untrained', 'Reflex'=>'untrained', 'Will'=>'untrained' }

    collection :abilities, "AresMUSH::Pf2eAbilities"
    collection :skills, "AresMUSH::Pf2eSkills"
    collection :lores, "AresMUSH::Pf2eLores"

    before_delete :delete_abilities

    def delete_abilities
      self.abilities.each { |a| a.delete }
      self.skills.each { |s| s.delete }
    end
  end

  class Pf2eAbilities < Ohm::Model
    include ObjectModel

    attribute :name
    attribute :base_val, :type => DataType::Integer, :default => 10
    attribute :mod_val, :default => false
    index :name

    reference :character, "AresMUSH::Character"
  end

  class Pf2eSkills < Ohm::Model
    include ObjectModel

    attribute :name
    attribute :proflevel
    index :name

    reference :character, "AresMUSH::Character"
  end

  class Pf2eLores < Ohm::Model
    include ObjectModel

    attribute :name
    attribute :proflevel
    index :name

    reference :character, "AresMUSH::Character"
  end

end
