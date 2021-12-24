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

    def self.check_alignment(align, charclass, subclass, deity=nil)
      return nil if !(Global.read_config('pf2e', 'use_alignment'))

      all_align = Global.read_config('pf2e','allowed_alignments')
      subclass_align = Global.read_config('pf2e_specialty', subclass, 'allowed_alignments')
      class_align = Global.read_config('pf2e_class', charclass, 'allowed_alignments')
      requires_deity = Global.read_config('pf2e_class', charclass, 'use_deity')
      deity_alignments = Global.read_config('pf2e_deities', deity, 'allowed_alignments')

      calign = class_align ? class_align : all_align
      salign = subclass_align ? subclass_align : all_align

      alignments = calign & salign

      if requires_deity && (!deity || deity.blank?)
        error = t('pf2e.class_requires_deity')
      elsif requires_deity
        dalign = alignments & deity_alignments
        error = dalign.include?(align) ?
                nil :
                t('pf2e.class_deity_mismatch')
      else
        error = alignments.include?(align) ? nil : t('pf2e.class_mismatch')
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

    def self.chargen_messages(ancestry, heritage, background, charclass, specialize, faith, subclass_info, to_assign=nil)
      messages = []

      missing_info = Pf2e.missing_base_info(ancestry, heritage, background, charclass, faith)
      messages << missing_info if missing_info

      bad_alignment = Pf2e.check_alignment(faith['alignment'], charclass, specialize, faith['deity'])
      messages << bad_alignment if bad_alignment

      needs_specialty = Global.read_config('pf2e', 'subclass_names').keys
      error = needs_specialty.include?(charclass) && specialize.blank?
      messages << t('pf2e.missing_subclass') if error

      needs_specialty_subinfo = !specialize.blank? && !charclass.blank? ?
        Global.read_config('pf2e_specialty', charclass, specialize) :
        {}
      missing_subclass_info = needs_specialty_subinfo.has_key?('choose') && subclass_info.blank?
      messages << t('pf2e.missing_subclass_info') if missing_subclass_info

      return nil if messages.count == 0
      return messages.join("%r")
    end

    def self.cg_edge_cases(char, charclass)
      case charclass
      when "Cleric"
        dfont_choice = deity_info['divine_font']

        if dfont_choice.size > 1
          to_assign['divine font'] = dfont_choice
        else
          # Do this code when spells are done, this should be tied to spells
        end
      else
        nil
      end
    end

    def self.update_sheet(char, info)
      info.each_pair do |key, value|
        case key
        when "choose_feat"
          to_assign = char.pf2_to_assign
          to_assign['feat_by_type'] = value
          char.update(pf2_to_assign: to_assign)
        when "charclass"
          features = char.pf2_features

          value.each { |f| features << f }

          char.update(pf2_features: features.uniq.sort)
        when "combat_stats"
          PF2eCombat.update_combat_stats(char, value)
        when "magic_stats"
          Pf2eMagic.update_magic_stats(char, value)
        when "skill"
        when "feat"
        when "action"
        when "reaction"
        when "familiar"
        when "animal companion"
        when "raise"
        when "choose"
        else
          client.emit_ooc "Unknown key in update_sheet: #{key}. Please raise this to code staff."
        end
      end
    end

  end
end
