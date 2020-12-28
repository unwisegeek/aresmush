module AresMUSH
  module AltTracker

    class RemoveAltCmd
      include CommandHandler

      attr_accessor :char

      def parse_args
        self.char = Character.find_one_by_name(cmd.args)
      end

      def check_alt_exists
        return nil if self.char
        return t('alttracker.does_not_exist')
      end

      def handle
        alt = self.char
        alt.update(player: nil)
        alt.update(approval_job: nil)
        alt.update(chargen_locked: false)
        Roles.remove_role(alt, "approved")

        client.emit_success t('alttracker.alt_removed,' :name => alt.name)
      end
    end

  end
end
