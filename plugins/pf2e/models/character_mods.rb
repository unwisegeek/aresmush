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
    attribute :pf2_faith, :type => DataType::Hash, :default => { 'deity'=>"", 'alignment'=>"" }
    attribute :pf2_special, :type => DataType::Array, :default => []
    attribute :pf2_boosts_working, :type => DataType::Hash, :default => { 'free'=>[], 'ancestry'=>[], 'background'=>[], 'charclass'=> [] }
    attribute :pf2_boosts, :type => DataType::Hash, :default => {}
    attribute :pf2_lang, :type => DataType::Array, :default => []
    attribute :pf2_viewsheet, :type => DataType::Hash, :default => {}
    attribute :pf2_to_assign, :type => DataType::Hash, :default => {}
    attribute :pf2_cg_assigned, :type => DataType::Hash, :default => {}
    attribute :pf2_size, :default => ""
    attribute :pf2_movement, :type => DataType::Hash, :default => {}

    collection :abilities, "AresMUSH::Pf2eAbilities"
    collection :skills, "AresMUSH::Pf2eSkills"
    collection :lores, "AresMUSH::Pf2eLores"
    reference :hp, "AresMUSH::Pf2eHP"
    reference :combat, "AresMUSH::Pf2eCombat"

    before_delete :delete_sheet

    def delete_sheet
      self.abilities&.each { |a| a.delete } if self.abilities
      self.skills&.each { |s| s.delete } if self.skills
      self.lores&.each { |l| l.delete } if self.lores
      self.hp&.delete
      self.combat&.delete
    end
  end
end
