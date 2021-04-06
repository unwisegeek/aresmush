module AresMUSH
  module Pf2eFeats

    def self.find_feat(type,term)

      string = term.upcase
      all_feats = Global.read_config('pf2e_feats', type)

      return nil if !all_feats

      details = {}
      all_feats = all_feats.keys.map { |f| f.upcase }

      match = all_feats.select { |f| f.match?(string) }

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
      if type == "ancestry"
        cinfo = char.pf2_base_info
        ancestry = [ cinfo["ancestry"], cinfo["heritage"] ].map { |a| a.downcase }
        match = details["traits"] && ancestry

        msg << "ancestry" if match.empty?
      elsif type == "charclass"
        cinfo = char.pf2_base_info
        charclass = [ cinfo["charclass"] ].map { |c| c.downcase }

        # Charclass can also match a dedication
        if !(details["traits"].include? charclass)
          dedication = cinfo["dedication"].map { |d| d.downcase }
          dmatch = details['traits'] && dedication
          if dmatch.empty?
            msg << "charclass"
          end
        end
      end

      # Prereq check, prerequisites includes level
      effective_level = char.pf2_level

      fails_prereqs = prereq_check(char, type, feat, effective_level)

      msg << "prerequisites" if fails_prereqs

      return nil if msg.empty?
      return msg
    end

    def self.prereq_check(char, type, feat, level)
      msg = []

      name = feat.split.map { |word| word.capitalize }

      details = Global.read_config('pf2e_feats', type, name)

      prereqs = details['prereqs']

      prereqs.each_pair do |ptype, required|

        if required =~ /\//
          string = required.split("/")
          factor = string[0]
          minimum = string[1]
        end

        case ptype
        when "level"
          msg << "level" if details["level"] > level
        when "ability"
          char_score = Pf2eAbilities.get_ability_score(char, factor)
          msg << "ability" if char_score < minimum
        when "skill"
          char_proficiency = Pf2e.get_prof_bonus(Pf2eSkills.get_skill_prof char, factor)
          min_proficiency = Pf2e.get_prof_bonus(minimum)

          msg << "skill" if char_proficiency < min_proficiency
        when "specialize"
          kit = char.pf2_base_info["specialize"].upcase
          msg << "specialize" if required.upcase != kit
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
          char_proficiency = Pf2e.get_prof_bonus(Pf2eLores.get_lore_prof char, factor)
          min_proficiency = Pf2e.get_prof_bonus(minimum)

          msg << "lore" if char_proficiency < min_proficiency
        when "heritage"
          heritage = char.pf2_base_info["heritage"].upcase
          msg << "heritage" if required.upcase != heritage
        end
      end
    end

  end
end
