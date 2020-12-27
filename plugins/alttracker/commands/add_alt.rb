module AresMUSH
  module AltTracker

    class ViewAltsCmd
      include CommandHandler

      def parse_args
        if cmd.args
          valid_email = /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
          if cmd.args =~ valid_email
            self.char = AltTracker.find_player_by_email(cmd.args)
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
        template = AltsDisplayTemplate.new(self.email, self.codeword, altlist, banned)

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

  end
end
