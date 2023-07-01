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

      def handle
        # Demand that the organizer be in a scene. 

        scene = enactor_room.scene

        if !scene 
          client.emit_failure t('pf2e.must_be_in_scene')
          return
        end

        # If no argument, initiative is based on Perception.
        init_stat = self.init ? self.init : 'Perception'

        valid_init_stat = Pf2e.is_valid_init_stat?(init_stat)

        if !valid_init_stat 
          client.emit_failure t('pf2e.not_unique')
          return
        end

        # Do it.

        encounter = PF2Encounter.create(
          organizer: enactor.name,
          scene: scene,
          init_stat: init_stat
        )

        template = PF2EncounterStart.new(encounter)

        message = template.render

        # Log the init start in the encounter. 
        PF2Encounter.send_to_encounter(encounter, message)

        # Log the initiative message to the scene as an OOC message. 
        Scenes.add_to_scene(scene, message, Game.master.system_character, false, true)
        
        # Notify all participants that an encounter has started.
        Global.notifier.notify_ooc(:pf2_combat, message) do |char|
          char && scene.participants.include?(char)
        end

      end

    end

  end
end