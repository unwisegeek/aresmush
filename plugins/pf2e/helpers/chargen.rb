module AresMUSH
  module Pf2e

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
      end

      return error if error
      return nil
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

      restricted = []

      a_rare = ancestry.blank? ? nil : Global.read_config('pf2e_ancestry', ancestry)['rare']
      b_rare = background.blank? ? nil : Global.read_config('pf2e_background', background)['rare']
      h_rare = heritage.blank? ? nil : Global.read_config('pf2e_heritage', heritage)['rare']

      restricted << "ancestry" if a_rare
      restricted << "background" if b_rare
      restricted << "heritage" if h_rare

      messages << t('pf2e.no_double_mojo') if restricted.count > 1

      return nil if messages.empty?
      return messages.join("%r")
    end

    def self.chargen_warn_player(char)
      messages = []

      feat_list = char.pf2_feats.values.flatten
      dup_feats = feat_list != feat_list.uniq

      messages << t('pf2e.duplicate_feats') if dup_feats

    end

    def self.cg_edge_cases(char, charclass, heritage, background)
      case charclass
      when "Cleric"
        dfont_choice = deity_info['divine_font']

        if dfont_choice.size > 1
          to_assign['divine font'] = dfont_choice
        else
          magic = char.magic
          magic.update(divine_font: dfont_choice)
        end
      else
        nil
      end
    end

    def self.update_sheet(char, info)
      # This is called by the advancement code and should be called by commit info. Fix commit info to do this.

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

    def self.assignments_complete?(char)
      # Assignments are incomplete if any value is "open".
      to_assign = char.pf2_to_assign

      to_assign.each_pair do |k,v|
        next unless v.include? "open"
        return false
      end

      return true
    end

  end
end
