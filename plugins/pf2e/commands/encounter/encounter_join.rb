module AresMUSH
  module Pf2e

    class PF2InitJoinCmd
      include CommandHandler

      attr_accessor :enc_id, :init_stat

      def parse_args
        args = cmd.parse_args(ArgParser.arg1_equals_optional_arg2)

        self.enc_id = integer_arg(args.arg1)
        self.init_stat = titlecase_arg(args.arg2)

      end

      def required_args
        [self.enc_id]
      end

      def check_used_encounter_ID
        return nil unless self.enc_id.zero?
        return t('pf2e.bad_id', :type => 'encounter')
      end

      def handle
        # Is this a valid encounter?

        encounter = PF2Encounter[self.enc_id]

        if !encounter
          client.emit_failure t('pf2e.bad_id', :type => 'encounter')
          return
        end 

        # Can the character join this encounter? 

        scene = encounter.scene
        cannot_join = Pf2e.check_encounter_join(enactor, scene)

        if cannot_join
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