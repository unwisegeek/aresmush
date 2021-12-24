module AresMUSH
  module Pf2e
    class PF2AssignBoostsCmd
      include CommandHandler

      def parse_args



      end

      def check_chargen_or_advancement

        if enactor.chargen_locked && !enactor.advancing || enactor.is_admin?
          return t('pf2e.only_in_chargen')
        elsif !enactor.chargen_stage
          return t('chargen.not_started')
        else
          return nil
        end
      end

      def handle
        # Verify that there are things to be assigned that this command handles.

      end

    end
  end
end
