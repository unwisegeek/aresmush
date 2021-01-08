module AresMUSH
  module AltTracker

    class RegisterAltPlayerCmd
      include CommandHandler

      attr_accessor :codeword, :target

      def parse_args
        args = cmd.parse_args(ArgParser.arg1_equals_arg2)
        self.target = trim_arg(args.arg1)
        self.codeword = trim_arg(args.arg2)
      end

      def required_args
        [ self.target, self.codeword ]
      end

      def handle
        valid_email = /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
        max_alts = Global.read_config('alttracker','max_alts_allowed')

        # Use safe navigation operator to force player to nil if character
        # not found.
        if self.target =~ valid_email
          player = AltTracker.find_player_by_email(self.target)
        else
          player = Character.find_one_by_name(self.target)&.player
        end

        if !player
          client.emit_failure t('alttracker.not_registered', :name => self.target)
          return nil
        elsif player.characters.size >= max_alts
          client.emit_failure t('alttracker.max_alts_exceeded', :max_alts => max_alts)
          return nil
        elsif player.banned
          client.emit_failure t('alttracker.player_banned')
          return nil
        elsif !(self.codeword == player.codeword)
          client.emit_failure t('alttracker.invalid_codeword')
          return nil
        else
          enactor.update(player: player)
          player.update(mark_idle: nil)
          client.emit_success t('alttracker.register_ok')
        end

      end
    end

  end
end
