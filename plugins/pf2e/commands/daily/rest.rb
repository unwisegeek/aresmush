module AresMUSH
  module Pf2e

    class PF2DailyPrepCmd
      include CommandHandler

      def handle

        prep_error = PF2e.do_daily_prep(enactor)

        if prep_error
          client.emit_failure prep_error
          return
        end

        client.emit_success t('pf2e.daily_prep_ok')

      end

    end

  end
end
