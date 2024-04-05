module AresMUSH
  module Pf2e

    class PF2AdvanceRaiseCmd
      include CommandHandler

      def check_advancing
        return nil if enactor.advancing
        return t('pf2e.not_advancing')
      end

      def handle


      end

    end
  end
end
