module AresMUSH
  class PF2Encounter < Ohm::Model
    include ObjectModel

    attribute :name
    attribute :participants, :type => DataType::Array, :default => []
    attribute :next_init, :type => DataType::Integer, :default => 0
    attribute :organizer
    attribute :is_active, :type => DataType::Boolean, :default => true
    attribute :round, :type => DataType::Integer, :default => 1
    attribute :current
    attribute :messages, :type => DataType::Array, :default => []
    attribute :init_stat
    attribute :bonuses, :type => DataType::Hash, :default => {}
    attribute :penalties, :type => DataType::Hash, :default => {}

    set :characters, "AresMUSH::Character"
    reference :scene, "AresMUSH::Scene"

    ##### CLASS METHODS #####

    def self.in_active_encounter?(char)
      char.encounters.any? { |e| e.is_active }
    end

    def self.active_encounter_in_scene(char, scene) 
      char_active_encounters = char.encounters.select { |e| e.is_active }
      scene_active_encounters = scene.encounters.select { |e| e.is_active }

      char_active_encounters.intersection(scene_active_encounters).first
    end

    def self.active_encounter(char)
      char.encounters.select { |e| e.is_active }.first
    end

    def self.send_to_encounter(enc, msg)
      message_list = enc.messages
      message_list < [ Time.now, msg ]
      enc.update(messages: message_list)
    end

    def self.add_to_initiative(encounter, name, roll, is_adversary=false)
      list = encounter.participants

      adversary_mod = is_adversary ? 0.2 : 0

      init = roll + adversary_mod

      list << [ init, name ]

      list_sort = list.sort_by { |p| -p[0] }

      encounter.update(participants: list_sort)
    end



  end
end
