module AresMUSH
  module Pf2e
    class PF2DamageResetCmd
      include CommandHandler

      attr_accessor :target, :damage

      def check_is_organizer
        return nil
      end

      def handle

        

      end

    end
  end
end
