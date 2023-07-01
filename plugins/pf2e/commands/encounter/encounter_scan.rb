module AresMUSH
  module Pf2e
    class PF2EncounterScanCmd
      include CommandHandler

      attr_accessor :encounter_id

      def parse_args
        self.encounter_id = integer_arg(cmd.args)
      end

      def check_valid_encounter
        # They don't have to specify an encounter ID, but if they do, make sure it's valid.
        return nil unless self.encounter_id
        return nil if PF2Encounter[self.encounter_id]
        return t('pf2e.bad_id', :type => 'encounter')
      end 

      def handle 
        # Since specifying an encounter ID is optional, we have to validate a few things.

        encounter = self.encounter_id ? PF2Encounter[self.encounter_id] : Pf2e.active_encounter(enactor)

        if !encounter
          client.emit_failure t('pf2e.bad_id', :type => 'encounter')
          return
        end

        if encounter.organizer != enactor.name
          client.emit_failure t('pf2e.not_organizer')
          return
        end

        template = PF2EncounterScanTemplate.new(encounter)

        client.emit template.render

      end


    end
  end
end