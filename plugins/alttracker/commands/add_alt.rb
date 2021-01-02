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

        new = Character.find_one_by_name(self.newchar)
        existing = Character.find_one_by_name(self.alt)

        if !(new && existing)
          client.emit_failure t('alttracker.one_does_not_exist', :new => self.newchar, :existing => self.alt)
          return nil
        else
          player = existing.player

          if !player
            client.emit_failure t('alttracker.not_registered', :name => existing.name)
            return nil
          elsif player.banned
            client.emit_failure t('alttracker.player_banned')
            return nil
          else
            new.update(player: player)
            client.emit_success t('alttracker.alt_manual_add', :newname => new.name, :alt => existing.name)
          end
        end

      end
    end

  end
end
