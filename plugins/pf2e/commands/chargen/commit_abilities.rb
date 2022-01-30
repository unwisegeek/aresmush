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

        to_assign = enactor.pf2_to_assign

        int_mod = Pf2eAbilities.abilmod(Pf2eAbilities.get_score(enactor, "Intelligence"))
        int_mod = int_mod.negative? ? 0 : int_mod

        open_skills = to_assign["open skills"]
        int_skills = [].fill("open", nil, int_mod)

        to_assign['open skills'] = open_skills + int_skills
        to_assign['open language'] = int_mod

        # Calculate new HP

        level = enactor.pf2_level
        hp_from_con = Pf2eAbilities.abilmod(Pf2eAbilities.get_score(enactor, 'Constitution')) * level
        ahp = heritage_info['ancestry_HP'] ? heritage_info['ancestry_HP'] : ancestry_info["HP"]
        max_base_hp = ahp + charclass_info["HP"]
        max_cur_hp = max_base_hp + hp_from_con

        hp.current = max_cur_hp
        hp.max_base = max_cur_hp
        hp.max_current = max_cur_hp
        hp.base_for_level = max_base_hp
        hp.save

        enactor.pf2_to_assign = to_assign
        enactor.pf2_abilities_locked = true
        enactor.save

        client.emit_success t('pf2e.abilities_committed')

      end
    end
  end
end
