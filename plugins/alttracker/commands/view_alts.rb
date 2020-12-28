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

        if self.target =~ valid email
          player = AltTracker.find_player_by_email(self.target)
        elsif self.target == enactor
          player = self.target
        else
          ClassTargetFinder.with_a_character(self.target, client, enactor) do |model|
            player = model.player
          end
        end

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
