module AresMUSH
  module Pf2e

    class PF2InitJoinCmd
      include CommandHandler

      attr_accessor :encounter_id, :init_stat

      def parse_args
        args = trimmed_list_arg(cmd.args, "=")

        self.encounter_id = integer_arg(args[0])
        self.init_stat = args[1]

      end

      def handle
        # If they didn't specify encounter ID, go get it. 

        scene = enactor_room.scene

        encounter = self.encounter_id ? 
          PF2Encounter[self.encounter_id] : 
          PF2Encounter.get_encounter_ID(enactor, scene)

        if !encounter
          client.emit_failure t('pf2e.bad_id', :type => 'encounter')
          return
        end

        # Can the character join this encounter? 

        can_join = Pf2e.can_join_encounter?(enactor, encounter)

        if !can_join
          client.emit_failure t('pf2e.cannot_join_encounter', :reason => cannot_join.join(", "))
          return
        end

        # If they specified an init stat, error if invalid, otherwise use the one
        # specified by the organizer. 

        init_stat = self.init_stat ? self.init_stat : encounter.init_stat

        if !Pf2e.is_valid_init_stat?(init_stat)
          client.emit_failure t('pf2e.not_unique')
          return
        end

        # Calculate initiative and add the enactor to the encounter participants list.

        initiative = Pf2e.parse_roll_string(enactor, "1d20+#{init_stat}")['total']

        PF2Encounter.add_to_initiative(encounter, enactor.name, initiative)

        # Set management for later use.

        enactor.encounters.add encounter
        encounter.characters.add enactor

        client.emit_success t('pf2e.encounter_joined_ok', :roll => initiative, :encounter => encounter.id)

      end 
    end 
  end
end