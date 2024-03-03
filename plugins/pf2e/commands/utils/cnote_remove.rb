module AresMUSH
  module Pf2e
    class PF2RemoveCnoteCmd
      include CommandHandler

      attr_accessor :character, :notename

      def parse_args
        # Argument pattern: [character/]notename
        args = trimmed_list_arg(cmd.args,"/")

        char_specified = args[1] ? true : false

        self.character = char_specified ? args[0] : nil
        self.notename = char_specified ? downcase_arg(args[1]) : downcase_arg(args[0])
      end

      def required_args
        [ self.notename ]
      end

      def

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

        # This time, I need to make sure that the notename in question exists and is unique.

        cnotes = char.pf2_cnotes

        note_list = cnotes.keys.select { |note| note.downcase == self.notename }

        unless note_list.size == 1
          client.emit_failure t('pf2e.not_unique')
          return
        end

        note = note_list.first

        cnotes.delete(note)

        char.update(pf2_cnotes: cnotes)

        client.emit_success t('pf2e.cnote_removed', :name => note, :char => char.name)

      end
    end
  end
end
