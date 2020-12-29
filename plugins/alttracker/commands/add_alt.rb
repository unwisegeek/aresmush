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
      end

      def check_can_modify
        return nil if enactor.has_permission?("manage_alts")
        return t('dispatcher.not_allowed')
      end

      def handle

        ClassTargetFinder.with_a_character(self.newchar, client, enactor) do |new|
          self.new = new
        end

        ClassTargetFinder.with_a_character(self.alt, client, enactor) do |existing|
          self.existing = existing
        end

        player = existing.player

        if !player
          client.emit_failure t('alttracker.not_registered', :name => self.existing.name)
        elsif player.banned
          client.emit_failure t('alttracker.player_banned')
        else
          self.new.update(player: player)
        end

        client.emit_success t('alttracker.alt_manual_add', :newname => self.new.name, :alt => self.existing.name)
      end
    end

  end
end
