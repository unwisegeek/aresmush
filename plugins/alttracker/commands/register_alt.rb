module AresMUSH
  module AltTracker

    class RegisterAltPlayerCmd
      include CommandHandler

      attr_accessor :codeword, :name

      def parse_args
        args = cmd.parse_args(ArgParser.arg1_equals_arg2)
        self.name = trim_arg(args.arg1)
        self.codeword = trim_arg(args.arg2)
      end

      def required_args
        [ self.name, self.codeword ]
      end

      def handle
        max_alts = Global.read_config('alttracker','max_alts_allowed')

        ClassTargetFinder.with_a_character(self.name, client, enactor) do |model|
          player = model.player

        if player.characters.size >= max_alts
          client.emit_failure t('alttracker.max_alts_exceeded', :max_alts => max_alts)
        elsif player.banned
          client.emit_failure t('alttracker.player_banned')
        elsif !(self.codeword == player.codeword)
          client.emit_failure t('alttracker.invalid_codeword')
        else
          enactor.update(player: player)
          client.emit_success t('alttracker.register_ok')
        end

        end

      end
    end

  end
end
