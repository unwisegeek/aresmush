module AresMUSH
  module Pf2e

    include CommonTemplateFields

    def self.get_feat_details(name)

      feat_info = Global.read_config('pf2e_feats', name)
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

    def self.can_take_feat?(char, feat)
      msg = []

      details = Pf2e.get_feat_details(feat)

      if !details
        return false
      end


      # Ancestry and character class checks
      # Dedication check for class feats is not done in this function.

      cinfo = char.pf2_base_info
      feat_type = details['feat_type']

      if feat_type.include? 'Charclass'
        charclass = cinfo['charclass']
        allowed_charclasses = details['assoc_charclass']

        msg << 'charclass' unless allowed_charclasses.include? charclass
      elsif feat_type.include? 'Ancestry'
        ancestry = cinfo['ancestry']
        allowed_ancestry = details['assoc_ancestry']

        msg << 'ancestry' unless allowed_ancestry == ancestry
      end

      # Prereq check, prerequisites includes level

      prereqs = details["prereq"]

      if prereqs 
        meets_prereqs = Pf2e.meets_prereqs?(char, prereqs)
      else
        meets_prereqs = true
      end

      msg << "prerequisites" if !meets_prereqs

      return true if msg.empty?
      return false
    end

    def self.meets_prereqs?(char, prereqs)
      msg = []

      prereqs.each_pair do |ptype, required|

        if required =~ /\//
          string = required.split("/")
          factor = string[0]
          minimum = string[1]
        end

        case ptype
        when "level"
          level = char.pf2_level

          msg << "level" if prereqs['level'] > level
        when "ability"
          char_score = Pf2eAbilities.get_score(char, factor)
          msg << "ability" if char_score < minimum.to_i
        when "skill"
          char_prof = Pf2e.get_prof_bonus(char, Pf2eSkills.get_skill_prof(char, factor))
          min_prof = Pf2e.get_prof_bonus(char, minimum)

          msg << "skill" if char_prof < min_prof
        when "specialize"
          if required.start_with?('!')
            banned = required.delete('!').upcase
            msg << "specialize" if banned == kit
          else
            kit = char.pf2_base_info["specialize"].upcase
            msg << "specialize" if required.upcase != kit
          end
        when "has_focus_pool"
          nil
        when "feat"
          feats = char.pf2_feats.values.flatten.map { |word| word.upcase }
          req = required.map { |word| word.upcase }

          msg << "feat" unless req.all? { |f| feats.include? f }
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
          msg << "special" unless char_specials.include?(required.upcase)
        when "tradition"
          magic = char.magic

          msg << "tradition" && next unless magic

          traditions = magic.tradition

          msg << "tradition" unless traditions.include? required
        when "combat_stats"
          combat = char.combat

          case factor
          when "Perception"
            prof = Pf2e.get_prof_bonus(char, combat.perception)
            min = Pf2e.get_prof_bonus(char, minimum)

            passes_check = min > prof ? false : true
          end

          msg << "combat_stats" unless passes_check
        when "orfeat"
          feats = char.pf2_feats.values.flatten.map { |word| word.upcase }
          req = required.map { |word| word.upcase }

          msg << "feat" unless req.any? { |f| feats.include? f }
        when "orheritage"
          heritage = char.pf2_base_info["heritage"]
          
          msg << "heritage" unless required.include? heritage
        when "orskill"
          check = []
          required.each do |s|

          string = s.split("/")
          factor = string[0]
          minimum = string[1]

          char_prof = Pf2e.get_prof_bonus(char, Pf2eSkills.get_skill_prof(char, factor))
          min_prof = Pf2e.get_prof_bonus(char, minimum)

          check << char_prof - min_prof
          end

          msg << "orskill" unless check.any? { |i| i>= 0 }
        else
          msg << "missing_prereq_check #{ptype}"
        end
      end

      return true if msg.empty?
      return false
    end
   

    def self.has_feat?(char, feat)
      feat_list = char.pf2_feats.values.flatten.map { |f| f.upcase }

      feat_list.include?(feat.upcase)
    end

    def self.generate_list_details(featlist)

      feat_list=featlist

      @details = Global.read_config('pf2e_feats').keep_if { |k,v| feat_list.include? k }

      list = []
      @details.each_pair do |feat, details|
        list << format_feat(feat, details)
      end

      list.sort

    end

    def self.get_feat_options(char, type)
      feats = Global.read_config('pf2e_feats')
      ftype = type.capitalize

      list = []

      feats.each_pair do |name, details|

        can_take = can_take_feat?(char, name)
        is_of_type = details['feat_type'].include? ftype
        has_feat = has_feat?(char, name)

        list << name if (can_take && is_of_type && !has_feat)

      end

      list.sort

    end

    def self.format_feat(feat, details)

      return t('pf2e.feat_details_missing', :name => feat.upcase) if !details

      fmt_name = "%x172#{feat}%xn"
      feat_type = "%xh%xwFeat Type:%xn #{details['feat_type'].sort.join(", ")}"
      
      # Depending on feat type, this may be different keys with different formats.

      if details.has_key? 'assoc_charclass'
        associated = "%x229Associated To:%xn #{details['assoc_charclass'].sort.join(", ")}"
      elsif details.has_key? 'assoc_ancestry'
        associated = "%x229Associated To:%xn #{details['assoc_ancestry'].sort.join(", ")}"
      elsif details.has_key? 'assoc_skill'
        associated = "%x229Associated To:%xn #{details['assoc_skill']}"
      else
        associated = "%x229Associated To:%xn Any"
      end

      traits = "%x229Traits:%xn #{details['traits'].sort.join(", ")}"
      
      # Prerequisites needs its own level of formatting.

      prereq_list = []
      
      details['prereq'].each_pair do |k,v|
        prereq_list << "%r%t%xh%xw#{k.capitalize}:%xn #{v}"
      end

      prereqs = "%x229Prerequisites:%xn #{prereq_list.join()}"

      desc = "%x229Description:%xn #{details['shortdesc']}"

      "#{fmt_name}%r%r#{feat_type}%r#{associated}%r#{traits}%r#{prereqs}%r#{desc}"
    end

    def self.feat_messages(char)
      msgs = []
      to_assign = char.pf2_to_assign
      charclass = char.pf2_base_info['charclass']
      ancestry = char.pf2_base_info['ancestry']

      if to_assign['charclass feat'] 
        msgs << t('pf2e.unassigned_class_feat') if to_assign['charclass feat'] == charclass
      end
      
      if to_assign['ancestry feat']
        msgs << t('pf2e.unassigned_ancestry_feat') if to_assign['ancestry feat'] == ancestry
      end

      return nil if msgs.empty?
      return msgs
    end

  end
end
