module AresMUSH
  module Pf2e
    class PF2CommitAbilitiesCmd
      include CommandHandler

      def check_in_chargen
        return nil unless ( enactor.is_approved? || enactor.is_admin? )
        return nil if enactor.chargen_stage
        return t('pf2e.only_in_chargen')
      end

      def handle
        if !enactor.pf2_baseinfo_locked
          client.emit_failure t('pf2e.lock_info_first')
          return
        elsif enactor.pf2_abilities_locked
          client.emit_failure t('pf2e.abilities_locked')
          return
        end

        if Pf2eAbilities.abilities_messages(enactor)
          client.emit_failure t('pf2e.cg_issues')
          return
        end

        cg_boosts = enactor.pf2_boosts_working.flatten

        cg_boosts.each do |b|
          Pf2eAbilities.update_base_score(enactor, b)
        end

        to_assign = enactor.pf2_to_assign
        to_assign = to_assign.delete_if { |k, v| k.match? "boost" }

        int_mod = Pf2eAbilities.get_ability_mod(Pf2eAbilities.get_ability_score(enactor, "Intelligence"))
        int_mod = int_mod.negative? ? 0 : int_mod

        open_skills = to_assign["open skills"]
        to_assign["open skills"] = open_skills + int_mod
        to_assign["open language"] = int_mod

        enactor.update(pf2_boosts: boosts)
        enactor.update(pf2_boosts_working: {})
        enactor.update(pf2_to_assign: to_assign)
        enactor.update(pf2_abilities_locked: true)

        client.emit_success t('pf2e.abilities_committed')

      end
    end
  end
end
