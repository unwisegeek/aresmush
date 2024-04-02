module AresMUSH
  module Pf2e

    class PF2ADvancementStartCmd
      include CommandHandler

      def handle
        # Verify that the character can advance.
        advfail = Pf2e.can_advance(enactor)

        if advfail
          client.emit_failure advfail
          return
        end

        # Gather information.
        level = char.pf2_level
        new_level = level + 1




        # Send information for processing.
        Pf2e.assess_advancement(enactor,info)

      end


    end
  end
end
