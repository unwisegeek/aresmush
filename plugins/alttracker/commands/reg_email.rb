module AresMUSH
  module AltTracker

    class ChangeEmailCmd
      include CommandHandler

      def parse_args
        self.email = trim_arg(cmd.args)
      end

      def required_args
        [ self.email ]
      end

      def check_valid_email
        valid_email = /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
        return nil if self.email =~ valid_email
        return t('alttracker.invalid_email')
      end

      def handle
        player = enactor.player

        if player
          player.update(email: self.email)
          client.emit_success t('alttracker.email_ok')
        else
          client.emit_failure t('alttracker.not_registered', :name => enactor.name)
        end
      end

    end

  end
end
