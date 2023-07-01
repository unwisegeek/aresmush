module AresMUSH
  module Pf2e
    class PF2EncounterScanTemplate < ErbTemplateRenderer
      include CommonTemplateFields

      attr_accessor :encounter

      def initialize(encounter)
        @encounter = encounter

        super File.dirname(__FILE__) + "/encounter_scan.erb"
      end

      
    end
  end
end