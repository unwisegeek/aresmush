module AresMUSH
  module AltTracker

    class BanAltCmd
      include CommandHandler

      def parse_args
        args = cmd.parse_args(ArgParser.arg1_equals_arg2)
        self.player = AltTracker.find_player_by_email(args.arg1)
        self.reason = args.arg2.to_s
      end

      def check_can_modify
        return nil if enactor.has_permission?("manage_alts")
        return t('alttracker.command_not_allowed')
      end

      def check_player_exists
        return nil if self.player
        return t('alttracker.player_not_found', :email => cmd.args)
      end

      def handle
        self.player.characters do |alt|
          alt.update(player: nil)
          alt.update(approval_job: nil)
          alt.update(chargen_locked: false)
        end

        self.player.update(banned: self.reason)
        client.emit_success "Player #{self.player.email} banned from gameplay and all alts unapproved. Reason: #{self.reason}"
      end
      
    end

  end
end
