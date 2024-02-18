module AresMUSH
  module Pf2e

    class PF2DailyPrepCmd
      include CommandHandler

      def handle

        prep_ok = PF2e.do_daily_prep(enactor)

        if !prep_ok
          client.emit_failure t('pf2e.daily_prep_error')
          return
        end

        client.emit_success t('pf2e.daily_prep_ok')

      end

    end

  end
end
