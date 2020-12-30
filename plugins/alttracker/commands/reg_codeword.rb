module AresMUSH
  module AltTracker

    class ChangeCodeWordCmd
      include CommandHandler

      attr_accessor :codeword

      def parse_args
        self.codeword = trim_arg(cmd.args).to_s
      end

      def required_args
        [ self.codeword ]
      end

      def handle
        player = enactor.player

        if player
          player.update(codeword: self.codeword)
          client.emit_success t('alttracker.codeword_ok')
        else
          client.emit_failure t('alttracker.not_registered', :name => enactor.name)
        end
      end

    end

  end
end
