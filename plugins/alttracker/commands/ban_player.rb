module AresMUSH
  module AltTracker

    class BanPlayerCmd
      include CommandHandler

      attr_accessor :player, :reason

      def parse_args
        args = cmd.parse_args(ArgParser.arg1_equals_arg2)
        self.name = trim_arg(args.arg1)
        self.reason = trim_arg(args.arg2).to_s
      end

      def check_can_modify
        return nil if enactor.has_permission?("manage_alts")
        return t('dispatcher.not_allowed')
      end

      def handle
        ClassTargetFinder.with_a_character(self.name,client) do |char|
          if char.player
            player = char.player
          else
            client.emit_failure t('alttracker.not_registered')
          end
        end

        return nil unless player

        player.characters do |alt|
          alt.update(player: nil)
          alt.update(approval_job: nil)
          alt.update(chargen_locked: false)
        end

        player.update(banned: self.reason)
        client.emit_success "Player #{player.email} banned from gameplay and all alts unapproved. Reason: #{self.reason}"
      end

    end

  end
end
