module AresMUSH
  module Pf2e
    class PF2ReviewChargenCmd
      include CommandHandler

      attr_accessor :target

      def parse_args
        self.target = trim_arg(cmd.args)
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
        char = Pf2e.get_character(self.target, enactor)

        if char.is_admin?
          client.emit_failure t('pf2e.admin_no_sheet')
          return nil
        end

        template = self.target.pf2_baseinfo_locked ?
          PF2CGReviewLockDisplay.new(char, client) :
          PF2CGReviewUnlockDisplay.new(char, client)

        client.emit template.render
      end
    end
  end
end
