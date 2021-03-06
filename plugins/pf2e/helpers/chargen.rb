module AresMUSH
  module Pf2e

    def self.can_take_feat?(char, feat)
      error = FeatValidator.req_check(char, feat)
      if error
        return false
      else
        return true
      end
    end

    def self.check_alignment(align, charclass, deity=nil)
      class_alignments = Global.read_config('pf2e_class', charclass, 'allowed_alignments')
      requires_deity = Global.read_config('pf2e_class', charclass, 'check_deity')
      deity_alignments = Global.read_config('pf2e_deities', deity, 'allowed_alignments')

      if !class_alignments
        class_alignments = Global.read_config('pf2e', 'allowed_alignments')
      end

      if requires_deity && (!deity || deity.blank?)
        error = t('pf2e.class_requires_deity')
      elsif requires_deity
        error = class_alignments & deity_alignments.include?(align) ? nil : t('pf2e.class_deity_mismatch')
      else
        error = class_alignments.include?(align) ? nil : t('pf2e.class_mismatch')
      end

      return error if error
      return nil
    end

    def self.missing_base_info(ancestry, heritage, background, charclass, faith_info)
      if ancestry.blank? || heritage.blank? || background.blank? || charclass.blank?
        error = t('pf2e.missing_base_info')
      else
        nil
      end
    end

    def self.chargen_messages(ancestry, heritage, background, charclass, specialize, faith)
      messages = []

      missing_info = Pf2e.missing_base_info(ancestry, heritage, background, charclass, faith)
      messages << missing_info if missing_info

      bad_alignment = Pf2e.check_alignment(faith['alignment'], charclass, faith['deity'])
      messages << bad_alignment if bad_alignment

      needs_specialty = Global.read_config('pf2e', 'subclass_names').keys
      error = needs_specialty.include?(charclass) && specialize.blank?
      messages << t('pf2e.missing_subclass') if error

      return nil if messages.count == 0
      return messages.join("%r")
    end

  end
end
