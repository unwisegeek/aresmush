module AresMUSH
  module Pf2e
    class PF2AddCnoteCmd
      include CommandHandler

      attr_accessor :character, :notename, :text

      def parse_args
        # Argument pattern: [character/]notename=text
        # I don't use Faraday's parser because the first argument is optional, which makes hers break.
        # Instead, I do it myself. args should resolve to a flat array.

        args = trimmed_list_arg(cmd.args, "/").map {|e| e.split("=")}.flatten

        char_specified = args[2] ? true : false

        self.character = char_specified ? downcase_arg(args[0]) : nil
        self.notename = char_specified ? titlecase_arg(args[1]) : titlecase_arg(args[0])
        self.text = char_specified ? trim_arg(args[2]) : trim_arg(args[1])
      end

      def required_args
        [ self.notename, self.text ]
      end

      def

      def check_permissions
        # Any character may modify their own; only people who can see alts can modify others'.

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

        # No validation for presence of keyname deemed necessary, onus is on the user not to duplicate keys.
        # They may do so intentionally for purposes of updating the key, if desired.

        cnotes = char.pf2_cnotes

        client.emit_ooc t('pf2e.cnote_updated', name => self.notename) if cnotes[self.notename]

        cnotes[self.notename] = self.text

        char.update(pf2_cnotes: cnotes)

        client.emit_success t('pf2e.cnote_added', :name => self.notename, :char => char.name)

      end
    end
  end
end
