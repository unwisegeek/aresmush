module AresMUSH
  module AltTracker

    class ViewAltsCmd
      include CommandHandler

      attr_accessor :target, :email, :codeword, :banned

      def parse_args
        if cmd.args
          self.target = cmd.args
        else
          self.target = enactor
        end
      end

      def check_can_view
        return nil if self.target == enactor
        return nil if enactor.has_permission?("manage_alts")
        return t('alttracker.view_own_alts')
      end

      def handle
        valid_email = /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i

        # Use safe navigation operator to force player to nil if character
        # not found.
        if self.target =~ valid_email
          player = AltTracker.find_player_by_email(self.target)
        elsif self.target == enactor
          player = enactor.player
        else
          player = Character.find_one_by_name(self.target)&.player
        end

        if !player
          if self.target == enactor
            display_name = enactor.name
          else
            display_name = cmd.args
          end

          client.emit_failure t('alttracker.not_registered', :name => display_name)
          return nil
        else
          email = player.email
          codeword = player.codeword
          altlist = player.characters.map { |n| n.name }.sort.join(", ")
          banned = player.banned
          template = AltsDisplayTemplate.new(email, codeword, altlist, banned)

          client.emit template.render
        end

      end
    end

  end
end
