module AresMUSH
  module Pf2e
    class PF2ReviewChargenCmd
      include CommandHandler

      def check_in_chargen
        return nil unless enactor.is_approved?
        return nil if enactor.chargen_stage
        return t('pf2e.only_in_chargen')
      end

      def handle
        sheet = enactor.pf2sheet

        if !enactor.pf2sheet
          client.emit_failure t('pf2e.sheet_not_found')
          return
        end

        template = PF2CGReviewDisplay.new(enactor, sheet, client)

        client.emit template.render
      end
    end
  end
end
