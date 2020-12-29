module AresMUSH
  module AltTracker

    class RemoveAltCmd
      include CommandHandler

      attr_accessor :char

      def parse_args
        self.char = cmd.args
      end

      def required_args
        [ self.char ]
      end

      def check_can_modify
        return nil if enactor.has_permission?("manage_alts")
        return t('dispatcher.not_allowed')
      end

      def handle
        ClassTargetFinder.with_a_character(self.char, client, enactor) do |model|
          model.update(player: nil)
          model.update(approval_job: nil)
          model.update(chargen_locked: false)
          Roles.remove_role(model, "approved")

        client.emit_success t('alttracker.alt_removed', :name => alt.name)
        end
      end
    end

  end
end
