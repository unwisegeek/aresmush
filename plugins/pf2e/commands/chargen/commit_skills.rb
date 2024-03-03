module AresMUSH
  module Pf2e

    class PF2CommitSkillsCmd
      include CommandHandler

      def check_in_chargen
        return nil if enactor.chargen_stage > 0 && !(enactor.is_approved?)
        return t('pf2e.only_in_chargen')
      end

      def check_skill_issues
        messages = Pf2eSkills.skills_messages(enactor)

        return t('pf2e.skill_issues') if messages
        return nil
      end

      def handle
        if enactor.pf2_skills_locked
          client.emit_failure t('pf2e.cg_locked', :cp => 'skills')
          return
        end

      end
    end

  end
end
