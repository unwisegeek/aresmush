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

      def check_valid_email
        valid_email = /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
        return nil if self.email =~ valid_email
        return t('alttracker.invalid_email')
      end

      def check_email_not_in_use
        return nil unless self.find_alts_by_email(self.email)
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

    class RegisterAltPlayerCmd
      include CommandHandler

      attr_accessor :alt, :codeword, :player

      def parse_args
        args = cmd.parse_args(ArgParser.arg1_equals_arg2)
        self.alt = Character.find_one_by_name(args.arg1)
        self.codeword = args.arg2
        self.player = self.alt.player
      end

      def check_alt_exists
        return nil if self.alt
        return t('alttracker.does_not_exist')
      end

      def check_player_not_banned
        return nil unless self.player.banned
        return t('alttracker.player_banned')
      end

      def check_valid_codeword
        return nil if self.codeword == self.player.codeword
        return t('alttracker.invalid_codeword')
      end

      def check_number_of_alts
        max_alts = Global.read_config(alttracker,max_alts_allowed)
        return nil if self.player.characters.size < max_alts
        return t('alttracker.max_alts_exceeded', :max_alts => max_alts)
      end

      def handle
        enactor.update(player: player)
        client.emit_success t('alttracker.register_ok')
      end

    end
  end
end
