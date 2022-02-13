module AresMUSH
  module Pf2e
    class PF2CommitAbilCmd
      include CommandHandler

      def check_in_chargen
        return nil if enactor.chargen_stage > 0
        return t('pf2e.only_in_chargen')
      end

      def check_abil_issues
        messages = Pf2eAbilities.abilities_messages(enactor)

        return t('pf2e.abil_issues') if messages
        return nil
      end

      def handle
        if enactor.pf2_abilities_locked
          client.emit_failure t('pf2e.cg_abilities_locked')
          return
        end

        enactor.pf2_abilities_locked = true

        to_assign = enactor.pf2_to_assign

        open_skills = to_assign['open skills']
        open_languages = to_assign.has_key?('open languages') ? to_assign['open languages'] : []
        int_mod = Pf2eAbilities.abilmod(Pf2eAbilities.get_score(enactor, 'Intelligence'))

        int_mod = 0 if int_mod < 1

        # If int_mod is positive, add that many open skills and languages

        if int_mod.positive?
          ary = []
          int_extras = ary.fill("open", nil, int_mod)

          to_assign['open skills'] = open_skills + int_extras
          to_assign['open languages'] = open_languages + int_extras

          enactor.pf2_to_assign = to_assign
        end

        enactor.save

        client.emit_success t('pf2e.abil_lock_ok')

      end
      
    end
  end
end
