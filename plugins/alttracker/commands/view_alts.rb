module AresMUSH
  module AltTracker

    class ViewAltsCmd
      include CommandHandler

      attr_accessor :char, :email, :codeword, :banned

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

      def check_alt_registered
        return nil if self.char.player
        return t('alttracker.not_registered', :name => self.char.name')
      end

      def handle
        player = self.char.player
        email = player.email
        codeword = player.codeword
        altlist = player.characters.map { |n| n.name }.sort
        banned = player.banned
        template = AltsDisplayTemplate.new(email, codeword, altlist, banned)

        client.emit template.render
      end
    end

  end
end
