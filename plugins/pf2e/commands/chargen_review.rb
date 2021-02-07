module AresMUSH
  module Pf2e
    class PF2ReviewChargenCmd
      include CommandHandler

      def parse_args
        self.target = cmd.args ? Character.find_one_by_name(cmd.args) : enactor
      end

      def check_in_chargen
        return nil if enactor.is_admin?
        if enactor.is_approved? || enactor.chargen_locked
          return t('pf2e.only_in_chargen')
        elsif !enactor.chargen_stage
          return t('chargen.not_started')
        else
          return nil
        end
      end

      def handle
        if !self.target
          client.emit_failure t('pf2e.char_not_found')
          return nil
        elsif self.target.is_admin?
          client.emit_failure t('pf2e.admin_no_sheet')
          return nil
        end

        template = PF2CGReviewDisplay.new(self.target, client)

        client.emit template.render
      end
    end
  end
end
