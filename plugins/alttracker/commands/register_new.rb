module AresMUSH
  module AltTracker
    class RegisterNewPlayerCmd
      include CommandHandler

      attr_accessor :email, :codeword

      def parse_args
        args = cmd.parse_args(ArgParser.arg1_equals_arg2)
        self.email = downcase_arg(args.arg1)
        self.codeword = args.arg2
      end

      def required_args
        [ self.email, self.codeword ]
      end

      def check_valid_email
        valid_email = /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
        return nil if self.email =~ valid_email
        return t('alttracker.invalid_email')
      end

      def check_email_not_in_use
        return nil unless AltTracker.find_player_by_email(self.email)
        return t('alttracker.email_in_use')
      end

      def handle
        player = Player.new

        player.update(email: self.email)
        player.update(codeword: self.codeword)
        enactor.update(player: player)

        client.emit_success t('alttracker.register_ok')
      end

    end

  end
end
