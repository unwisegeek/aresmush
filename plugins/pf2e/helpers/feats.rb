module AresMUSH
  module Pf2eFeats

    def self.find_feat(type,term)

      string = term.upcase
      all_feats = Global.read_config('pf2e_feats', type)

      return nil if !all_feats

      details = {}
      all_feats = all_feats.keys.map { |f| f.upcase }

      match = all_feats.select { |f| f.match?(string) }

      return nil if match.empty?

      values = match.each do |f|
        k = f.split.each { |word| word.capitalize }
        v = all_feats[k]
        details[k] = v
      end

      details
    end

    def self.find_feat_by_term(search_type, term)

    end

    def self.can_take_feat?(char, type, feat)
      msg = []

      name = feat.split.map { |word| word.capitalize }

      details = Global.read_config('pf2e_feats', type, name)

      if !details
        msg = "No such feat or bad feat type."
        return msg
      end

      # Ancestry and character class checks
      is_from_dedication = false

      if type == "ancestry"
        cinfo = char.pf2_base_info
        ancestry = [ cinfo["ancestry"], cinfo["heritage"] ].map { |a| a.downcase }
        match = details["traits"] && ancestry

        msg << "ancestry" if match.empty?
      elsif type == "charclass"
        cinfo = char.pf2_base_info
        charclass = [ cinfo["charclass"], cinfo["dedication"] ].flatten.map { |c| c.downcase }
        dmatch = details['traits'] && charclass

        if dmatch.empty?
          msg << "charclass"
          return msg
        end

        is_from_dedication = true if !dmatch.include?(cinfo['charclass'])
      end

      # Prereq check, prerequisites includes level

      effective_level = is_from_dedication ? (char.pf2_level / 2) : char.pf2_level

      prereqs = details["prereqs"]

      meets_prereqs = true

      if !(prereqs.empty?)
        meets_prereqs = meets_prereqs?(char, prereqs, effective_level)
      end

      msg << "prerequisites" if !meets_prereqs

      return true if msg.empty?
      return false
    end

    def self.meets_prereqs?(char, prereqs, level)
      msg = []
      orlist = {}

      prereqs.each_pair do |ptype, required|

        if required =~ /\//
          string = required.split("/")
          factor = string[0]
          minimum = string[1]
        end

        if ptype.start_with?("or")
          keytype = ptype.delete("or")
          orlist[keytype] = required
          next
        end

        case ptype
        when "level"
          msg << "level" if prereqs['level'] > level
        when "ability"
          char_score = Pf2eAbilities.get_score(char, factor)
          msg << "ability" if char_score < minimum
        when "skill"
          char_prof = Pf2e.get_prof_bonus(char, Pf2eSkills.get_skill_prof(char, factor))
          min_prof = Pf2e.get_prof_bonus(char, minimum)

          msg << "skill" if char_prof < min_prof
        when "specialize"
          if required.start_with?('!')
            banned = required.delete('!').set_upcase_name
            msg << "specialize" if banned == kit
          else
            kit = char.pf2_base_info["specialize"].upcase
            msg << "specialize" if required.upcase != kit
          end
        when "has_focus_pool"
          nil
        when "charclass"
          features = enactor.pf2_features.map { |word| word.upcase }
          req = required.upcase
          msg << "charclass" if !(features.include? req)
        when "feat"
          feats = enactor.pf2_feats.map { |word| word.upcase }
          req = required.upcase
          msg << "feat" if !(feats.include? req)
        when "lore"
          char_proficiency = Pf2e.get_prof_bonus(char, Pf2eLores.get_lore_prof(char, factor))
          min_proficiency = Pf2e.get_prof_bonus(char, minimum)

          msg << "lore" if char_proficiency < min_proficiency
        when "heritage"
          if required.start_with?('!')
            banned = required.delete('!').set_upcase_name
            msg << "heritage" if banned == heritage
          else
            heritage = char.pf2_base_info["heritage"].upcase
            msg << "heritage" if required.upcase != heritage
          end
        when "special"
          char_specials = char.pf2_special.each { |s| s.upcase }
          msg << "special" if !(char_specials.include?(required.upcase))
        end
      end

      return true if msgs.empty?
      return false
    end

    def self.has_feat?(enactor, feat)
      feat_list = enactor.pf2_feats.values.flatten.map { |f| f.upcase }

      feat_list.include?(feat.upcase)
    end

  end
end
