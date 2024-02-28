module AresMUSH
  module Pf2e
    class PF2ViewAllCnotesCmd
      include CommandHandler

      attr_accessor :character

      def parse_args
        self.character = upcase_arg(cmd.args)
      end

      def check_permissions
        # Any character may view their own; only people who can see alts can see others'.

        return nil if !self.character
        return nil if enactor.has_permission?('manage_alts')
        return t('dispatcher.not_allowed')
      end

      def handle

        # If no argument, code assumes reference is to self.

        char = Pf2e.get_character(self.character, enactor)

        if !char
          client.emit_failure t('pf2e.not_found')
          return
        end

        # The list of cnotes is a hash on the character. Grab and send straight to template for display.

        cnotes = char.pf2_cnotes

        template = PF2CNoteTemplate.new(char, cnotes, client)

        client.emit template.render

      end

    end
  end
end
