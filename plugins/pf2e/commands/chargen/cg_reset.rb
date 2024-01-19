module AresMUSH
  module Pf2e
    class PF2ResetChargenCmd
      include CommandHandler

      attr_accessor :confirm

      def parse_args
        self.confirm = cmd.args
      end

      def check_in_chargen
        if enactor.is_approved? || enactor.chargen_locked
          return t('pf2e.only_in_chargen')
        elsif !enactor.chargen_stage
          return t('chargen.not_started')
        else
          return nil
        end
      end

      def handle

        if (enactor.pf2_reset && !self.confirm)
          client.emit_ooc t('pf2e.must_confirm')
          return nil
        elsif !enactor.pf2_reset && self.confirm
          client.emit_failure t('pf2e.reset_first')
          return nil
        elsif !enactor.pf2_reset && !self.confirm
          client.emit_ooc t('pf2e.are_you_sure')
          enactor.update(pf2_reset: true)
          return nil
        end

        enactor.pf2_baseinfo_locked = false
        enactor.pf2_abilities_locked = false

        enactor.pf2_base_info = { 'ancestry'=>"", 'heritage'=>"", 'background'=>"", 'charclass'=>"", "specialize"=>"" }
        enactor.pf2_xp = 0
        enactor.pf2_conditions = {}
        enactor.pf2_features = []
        enactor.pf2_traits = []
        enactor.pf2_feats = { "ancestry"=>[], "charclass"=>[], "skill"=>[], "general"=>[] }
        enactor.pf2_faith = { 'deity'=>"", 'alignment'=>"" }
        enactor.pf2_special = []
        enactor.pf2_boosts_working = { 'free'=>[], 'ancestry'=>[], 'background'=>[], 'charclass'=>[] }
        enactor.pf2_boosts = {}
        enactor.pf2_to_assign = {}
        enactor.pf2_lang = []
        enactor.pf2_movement = {}

        # Reset money and gear if that plugin is installed.
        Pf2egear.reset_gear(enactor) if AresMUSH.const_defined?("Pf2egear")

        # All characters have all objects except magic, so to minimize DB bloat, reuse existing objects.
        Pf2eAbilities.factory_default(enactor)
        Pf2eSkills.factory_default(enactor)
        Pf2eHP.factory_default(enactor)
        Pf2eCombat.factory_default(enactor)
        enactor.magic&.delete

        enactor.pf2_reset = false

        enactor.save

        client.emit_success t('pf2e.cg_reset_ok')

      end

    end
  end
end
