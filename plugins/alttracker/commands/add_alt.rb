module AresMUSH
  module AltTracker

    class AddAltCmd
      include CommandHandler

      def parse_args
        args = cmd.parse_args(ArgParser.arg1_equals_arg2)
        self.newchar = Character.find_one_by_name(args.arg1)
        self.alt = Character.find_one_by_name(args.arg2)
        self.player = self.alt.player
      end

      def check_can_modify
        return nil if enactor.has_permission?("manage_alts")
        return t('alttracker.command_not_allowed')
      end

      def check_registered_alt
        return nil if self.alt && self.player
        return t('alttracker.not_registered', :name => self.alt.name)
      end

      def handle
        self.newchar.update(player: self.player)

        client.emit_success "#{self.newchar.name} registered under email #{self.player.email}."
      end
    end

  end
end
