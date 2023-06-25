module AresMUSH
  module Pf2e

    class PF2InitiateCombatCmd
      include CommandHandler

      attr_accessor :init

      def parse_args
        self.init = titlecase_arg(cmd.args)
      end

      def check_is_approved
        return nil if enactor.is_approved? 
        return t('dispatcher.not_allowed')
      end

      def check_is_in_scene
        return nil if enactor_room.scene
        return t('pf2e.must_be_in_scene')
      end

      def handle
        # If no argument, initiative is based on Perception.
        init_stat = self.init ? self.init : 'Perception'

        # DMs may ask for any ability, any skill, or Perception. This list is subject to expansion.
        abilities = [ 'Strength', 'Dexterity', 'Constitution', 'Intelligence', 'Wisdom', 'Charisma' ]
        skills = Global.read_config('pf2e_skills').keys
        combat_stats = ['Perception']

        valid_init_stat = abilities + skills + combat_stats

        # Is there a unique match? Error if no match or multiple matches

        usable_init_stat = valid_init_stat.map { |s| s.match? init_stat }

        if usable_init_stat.size > 1
          client.emit_failure t('pf2e.not_unique')
          return

        elsif usable_init_stat.empty?
          client.emit_failure t('pf2e.bad_value', :item => self.init)
        else 
          init_stat = usable_init_stat.first
        end

        # Do it. 

        scene = enactor_room.scene

        encounter = PF2Encounter.create(
          organizer: enactor.name
          scene: scene
          init_stat: init_stat
        )

        template = PF2EncounterStart.new(encounter)

        message = t('pf2e.encounter_started', :enc_id => encounter.id, :stat => init_stat)

        # Log the init start in the encounter. 
        PF2Encounter.send_to_encounter(encounter, message)

        # Log the initiative message to the scene as an OOC message. 
        Scenes.add_to_scene(scene, message, Game.master.system_character, false, true)
        
        # Emit the message to the room. 
        enactor_room.emit message

      end

    end

  end
end