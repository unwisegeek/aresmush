module AresMUSH
  module AltTracker

    class ViewAltsCmd
      include CommandHandler

      def parse_args
        if cmd.args
          valid_email = /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
          if cmd.args =~ valid_email
            self.char = Player.find_player_by_email(cmd.args)
          else
            self.char = Character.find_one_by_name(cmd.args)
          end
        else
          self.char = enactor
        end
      end

      def check_can_view
        return nil if self.char == enactor
        return nil if enactor.has_permission?("manage_alts")
        return t('alttracker.view_own_alts')
      end

      def check_alt_exists
        return nil if self.char
        return t('alttracker.does_not_exist')
      end

      def handle
        player = self.char.player
        altlist = player.characters.map { |n| n.name }.sort
        banned = player.banned
        template = AltDisplayTemplate.new(self.email, self.codeword, altlist, banned)

        client.emit template.render
      end
    end

    class AddAltCmd
      include CommandHandler

      def parse_args
        args = cmd.parse_args(ArgParser.arg1_equals_arg2)
        self.newchar = Character.find_one_by_name(args.arg1)
        self.alt = Character.find_one_by_name(args.arg2)
        self.player = self.alt.player
      end

      def check_can_modify
        return nil if enactor.has_permission?("manage_alts")
        return t('alttracker.command_not_allowed')
      end

      def check_registered_alt
        return nil if self.alt && self.player
        return t('alttracker.not_registered')
      end

      def handle
        self.newchar.update(player: self.player)

        client.emit_success "#{self.newchar.name} registered under email #{self.player.email}."
      end
    end

    class RemoveAltCmd
      include CommandHandler

      def parse_args
        self.char = Character.find_one_by_name(cmd.args)
      end

      def check_alt_exists
        return nil if self.char
        return t('alttracker.does_not_exist')
      end

      def handle
        alt = self.char
        alt.update(player: nil)
        alt.update(approval_job: nil)
        alt.update(chargen_locked: false)
        Roles.remove_role(alt, "approved")

        client.emit_success "#{self.char.name} unapproved for play and dissociated from player object."
      end
    end

    class BanAltCmd
      include CommandHandler

      def parse_args
        args = cmd.parse_args(ArgParser.arg1_equals_arg2)
        self.player = self.find_player_by_email(args.arg1)
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
