module AresMUSH
  module AltTracker

    class AddAltCmd
      include CommandHandler

      attr_accessor :alt, :newchar

      def parse_args
        args = cmd.parse_args(ArgParser.arg1_equals_arg2)
        self.newchar = trim_arg(args.arg1)
        self.alt = trim_arg(args.arg2)
      end

      def required_args
        [ self.newchar, self.alt ]

      def check_can_modify
        return nil if enactor.has_permission?("manage_alts")
        return t('dispatcher.not_allowed')
      end

      def handle
        ClassTargetFinder.with_a_character(self.newchar, client) do |new|
          new = new.name
        end

        ClassTargetFinder.with_a_character(self.alt, client) do |existing|
          existing = existing.name
        end

        player = existing.player

        if !player
          client.emit_failure t('alttracker.not_registered', :name => existing.name)
        elsif player.banned
          client.emit_failure t('alttracker.player_banned')
        else
          new.update(player: player)

          client.emit_success t('alttracker.alt_manual_add', :newname => self.newchar.name, :alt => self.alt.name)
        end
      end
    end

  end
end
