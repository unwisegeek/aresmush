module AresMUSH
  module Pf2e
    class PF2ConditionSetCmd
      include CommandHandler

      attr_accessor :target, :condition, :value

      def parse_args

      end

      def check_is_organizer
        return nil
      end

      def handle



      end

    end
  end
end
