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

      def check_confirm
        return nil unless self.confirm
        return nil if self.confirm.downcase == "confirm"
        return t('pf2e.must_confirm')
      end

      def handle

        if (enactor.pf2_reset && !self.confirm)
          client.emit_failure t('pf2e.must_confirm')
          return nil
        elsif !enactor.pf2_reset && self.confirm
          client.emit_failure t('pf2e.reset_first')
          return nil
        elsif !enactor.pf2_reset && !self.confirm
          client.emit_ooc t('pf2e.are_you_sure')
          enactor.update(pf2_reset: true)
          return nil
        end

        enactor.update(pf2_baseinfo_locked: false)

        enactor.update(pf2_base_info: { 'ancestry'=>"", 'heritage'=>"", 'background'=>"", 'charclass'=>"", "specialize"=>"" })
        enactor.update(pf2_level: 1)
        enactor.update(pf2_xp: 0)
        enactor.update(pf2_conditions: {})
        enactor.update(pf2_features: [])
        enactor.update(pf2_traits: [])
        enactor.update(pf2_feats: [])
        enactor.update(pf2_faith: { 'faith'=>"", 'deity'=>"", 'alignment'=>"" })
        enactor.update(pf2_special: [])
        enactor.update(pf2_boosts: { 'free'=>[], 'ancestry'=>[], 'background'=>[], 'charclass'=>[], 'unspent'=>4 })
        enactor.update(pf2_saves: { 'Fortitude'=>'untrained', 'Reflex'=>'untrained', 'Will'=>'untrained' })

        enactor.abilities&.each { |a| a.delete }
        enactor.skills&.each { |s| s.delete }
        enactor.lores&.each { |l| l.delete }
        enactor.hp&.delete

        client.emit_success t('pf2e.cg_reset_ok')

      end

    end
  end
end
