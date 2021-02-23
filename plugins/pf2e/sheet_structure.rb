module AresMUSH
  class Character
    attribute :pf2_baseinfo_locked, :type => DataType::Boolean
    attribute :pf2_abilities_locked, :type => DataType::Boolean
    attribute :pf2_reset, :type => DataType::Boolean

    attribute :pf2_base_info, :type => DataType::Hash, :default => { 'ancestry'=>"", 'heritage'=>"", 'background'=>"", 'charclass'=>"", "specialize"=>"" }
    attribute :pf2_level, :type => DataType::Integer, :default => 1
    attribute :pf2_xp, :type => DataType::Integer, :default => 0
    attribute :pf2_conditions, :type => DataType::Hash, :default => {}
    attribute :pf2_features, :type => DataType::Array, :default => []
    attribute :pf2_traits, :type => DataType::Array, :default => []
    attribute :pf2_feats, :type => DataType::Hash, :default => { "ancestry"=>[], "charclass"=>[], "skill"=>[], "general"=>[] }
    attribute :pf2_faith, :type => DataType::Hash, :default => { 'faith'=>"", 'deity'=>"", 'alignment'=>"" }
    attribute :pf2_special, :type => DataType::Array, :default => []
    attribute :pf2_boosts_working, :type => DataType::Hash, :default => { 'free'=>[], 'ancestry'=>[], 'background'=>[], 'charclass'=> [] }
    attribute :pf2_boosts, :type => DataType::Hash, :default => {}
    attribute :pf2_saves, :type => DataType::Hash, :default => { 'Fortitude'=>'untrained', 'Reflex'=>'untrained', 'Will'=>'untrained' }
    attribute :pf2_lang, :type => DataType::Array, :default => []
    attribute :pf2_viewsheet, :type => DataType::Hash, :default => {}
    attribute :pf2_to_assign, :type => DataType::Hash, :default => {}
    attribute :pf2_cg_assigned, :type => DataType::Hash, :default => {}
    attribute :pf2_size, :default => ""
    attribute :pf2_hp, :type => DataType::Hash, :default => {}
    attribute :pf2_movement, :type => DataType::Hash, :default => {}

    collection :abilities, "AresMUSH::Pf2eAbilities"
    collection :skills, "AresMUSH::Pf2eSkills"
    collection :lores, "AresMUSH::Pf2eLores"

    before_delete :delete_sheet

    def delete_sheet
      self.abilities.each { |a| a.delete } if self.abilities
      self.skills.each { |s| s.delete } if self.skills
      self.lores.each { |l| l.delete } if self.lores
    end
  end

  class Pf2eAbilities < Ohm::Model
    include ObjectModel
    include FindByName

    attribute :name
    attribute :name_upcase
    attribute :shortname
    attribute :base_val, :type => DataType::Integer, :default => 10
    attribute :mod_val, :default => false
    index :name_upcase

    before_save :set_upcase_name

    def set_upcase_name
      self.name_upcase = self.name.upcase
    end

    reference :character, "AresMUSH::Character"
  end

  class Pf2eSkills < Ohm::Model
    include ObjectModel
    include FindByName

    attribute :name
    attribute :name_upcase
    attribute :proflevel
    attribute :cg_skill, :type => DataType::Boolean
    index :name_upcase

    before_save :set_upcase_name

    def set_upcase_name
      self.name_upcase = self.name.upcase
    end

    reference :character, "AresMUSH::Character"
  end

  class Pf2eLores < Ohm::Model
    include ObjectModel
    include FindByName

    attribute :name
    attribute :name_upcase
    attribute :proflevel
    attribute :cg_lore, :type => DataType::Boolean
    index :name_upcase

    before_save :set_upcase_name

    def set_upcase_name
      self.name_upcase = self.name.upcase
    end

    reference :character, "AresMUSH::Character"
  end

end
