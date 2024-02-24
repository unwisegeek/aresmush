module AresMUSH
  module Pf2e

    class PF2AutoDailyPrepCmd
      include CommandHandler

      def handle
        value = toggle_auto_refresh(enactor)

        setting = value ? "ON" : "OFF"

        client.emit_success t('pf2e.autorest_set_ok', :setting => setting)
      end

    end

  end
end
