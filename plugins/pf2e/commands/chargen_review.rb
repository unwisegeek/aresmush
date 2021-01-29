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
        template = PF2CGReviewDisplay.new(enactor, client)

        client.emit template.render
      end
    end
  end
end
