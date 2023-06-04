module AresMUSH
  module Pf2e

    include CommonTemplateFields

    def self.get_feat_details(name)

      string = name.upcase 

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

      name = feat.split.map { |word| word.capitalize }.join

      details = get_feat_details(name)

      # Does the feat actually exist? get_feat_details returns a hash 
      # if it does and a string if it doesn't.

      if details.is_a? String
        msg << details
        return msg
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

      prereqs = details["prereqs"]

      meets_prereqs = true

      if prereqs 
        meets_prereqs = meets_prereqs?(char, prereqs)
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
          msg << "ability" if char_score < minimum
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
          feats = enactor.pf2_feats.values.flatten.map { |word| word.upcase }
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
          feats = enactor.pf2_feats.values.flatten.map { |word| word.upcase }
          req = required.map { |word| word.upcase }

          msg << "feat" unless req.any? { |f| feats.include? f }
        when "orheritage"
          heritage = char.pf2_base_info["heritage"]
          
          msg << "heritage" unless required.include? heritage
        else
          msg << "missing_prereq_check #{ptype}"
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
      feat_type = type.capitalize

      list = []

      feats.each_pair do |name, details|

        can_take = Pf2e.can_take_feat?(char, name)
        is_of_type = (details['feat_type'].include? feat_type) ? true : false

        list << name if (can_take && is_of_type)

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

  end
end
