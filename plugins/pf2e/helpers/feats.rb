module AresMUSH
  module Pf2e

    def self.get_feat_details(term)

      string = term.upcase 

      feat_info = Global.read_config('pf2e_feats')

      match = feat_info.select { |name, deets| name.match?(string) }

      return 'no_match' if match.empty?

      match
    end

    def self.search_feats(search_type, term)
      valid_search_types = [ 'name' ]

      return 'bad_search_type' unless valid_search_types.include? search_type

      feat_info = Global.read_config('pf2e_feats')

      case search_type
      when 'name'

        feat_names=feat_info.keys.map { |n| n.upcase }

        match = feat_names.select { |n| n.match? term }

      end

      return 'no_match' if match.empty?

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

      prereqs.each_pair do |ptype, required|

        if required =~ /\//
          string = required.split("/")
          factor = string[0]
          minimum = string[1]
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

    def self.generate_list_details(featlist)

      feat_list = featlist.sort

        @details = Global.read_config('pf2e_feats').keep_if { |k,v| feat_list.include? k }

        list = []
        @details.each_pair do |feat, details|
          list << format_feat(feat, details)
        end

    end

    def format_feat(feat, details)
      fmt_name = "#{title_color}#{feat}%xn"
      feat_type = "#{item_color}Feat Type:%xn #{details[feat_type].sort.join(", ")}"
      
      # Depending on feat type, this may be different keys with different formats.

      if details.has_key? assoc_charclass
        associated = "#{item_color}Associated To:%xn #{details[assoc_charclass].sort.join(", ")}"
      elsif details.has_key? assoc_ancestry
        associated = "#{item_color}Associated To:%xn #{details[assoc_ancestry].sort.join(", ")}"
      elsif details.has_key? assoc_skill
        associated = "#{item_color}Associated To:%xn #{details[assoc_skill]}"
      else
        associated = "Any"
      end

      traits = "#{item_color}Traits:%xn #{details[traits].sort.join(", ")}"
      
      # Prerequisites needs its own level of formatting.

      prereq_list = []
      
      details[prereq].each_pair do |k,v|
        prereq_list << "%r%t#{k.capitalize}: #{v}"
      end

      prereqs = "#{item_color}Prerequisites:%xn #{prereq_list.join()}"

      desc = "#{item_color}Description:%xn #{details[shortdesc]}"

      "#{fmt_name}%r%r#{feat_type}%r#{associated}%r#{traits}%r#{prereqs}%r#{desc}"
    end

  end
end
