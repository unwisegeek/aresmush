module AresMUSH
  module Pf2emagic

    def self.is_caster?(char)
      magic = char.magic
      return false unless magic

      trad = magic.tradition
      trad = trad.delete('innate')
      innate_only = trad.empty?

      innate_spells = magic.innate_spells

      return false if innate_only && innate_spells.empty?
      return true
    end

    def self.generate_spells_today(char)

      magic = char.magic

      spells_today = {}

      return t('pf2emagic.not_caster') unless magic

      pclass = magic.spells_prepared.keys.map { |c| c.downcase }

      sclass = magic.repertoire.keys.map { |c| c.downcase }

      class_list = (pclass + sclass).uniq

      class_list.each do |cc|
        case cc
        when "Wizard", "Druid", "Cleric", "Witch"
          prepared_list = magic.spells_prepared

          spells_today[cc] = prepared_list
        when "Bard", "Oracle", "Sorcerer"
          spontlist = generate_blank_spell_list(magic)

          spells_today[cc] = spontlist
        else
          return nil
        end

        magic.update(spells_today: spells_today)
      end

    end

    def self.do_refocus(target, enactor)

      # This is included because it validates the existence of a magic object.
      return t('pf2emagic.not_caster') unless is_caster?(target)

      magic, focus_pool = target.magic, magic.focus_pool

      current, max = focus_pool["current"], focus_pool["max"]

      # Max focus pool defaults to zero and is always 1-3 if target has a focus pool.
      return t('pf2emagic.no_focus_pool') if max.zero?

      # These checks are skipped if an admin is force-refocusing the target.
      if !enactor.is_admin?
        return t('pf2emagic.cant_refresh_pool') unless current.zero?

        last_refocus, current_time = magic.last_refocus, Time.now

        # Last refocus can be nil, use 0 epoch if it is

        last_refocus = Time.at(0) unless last_refocus

        elapsed = (current_time - last_refocus).to_i

        return t('pf2emagic.cant_refresh_time') unless (elapsed > 3600)
      end

      current = max

      focus_pool["current"] = current
      magic.update(focus_pool: focus_pool)
      magic.update(last_refocus: Time.now)

      return nil
    end

    def self.get_max_focus_pool(char, change)
      magic = char.magic

      return 0 unless magic

      # Calculate all the focus pool points that the character could have available.
      # From character class

      mstat_class = Global.read_config('pf2e_class', char.pf2_base_info['charclass'], 'chargen')['magic_stats']

      if mstat_class
        fp_from_charclass = mstat_class['focus_pool'] ? mstat_class['focus_pool'] : 0
      else
        fp_from_charclass = 0
      end

      # From feats
      all_feats = char.pf2_feats.values.flatten.uniq

      values = []

      all_feats.each do |feat|
        details = Pf2e.get_feat_details(feat)
        (values << 0 && next) if details.is_a? String

        mstats = details[1]['magic_stats']
        (values << 0 && next) unless mstats

        feat_fp = mstats['focus_pool']
        (values << 0 && next) unless feat_fp

        values << feat_fp
      end

      fp_from_feats = values.sum

      (fp_from_charclass + fp_from_feats + change).clamp(0,3)
    end

    def self.get_spell_details(term)
      result = get_spells_by_name(term)

      return t('pf2emagic.no_match', :item => "spells") if result.empty?
      return t('pf2e.multiple_matches', :element => 'spell') if result.size > 1

      spell_name = result.first

      spell_details = Global.read_config('pf2e_spells', spell_name)

      [ spell_name, spell_details ]
    end

    def self.search_spells(search_type, term, operator='=')
      spell_info = Global.read_config('pf2e_spells')

      case search_type
      when 'name'
        match = spell_info.select { |k,v| k.upcase.match? term.upcase }
      when 'traits'
        match = spell_info.select { |k,v| v['traits'].include? term.downcase }
      when 'level'
        # Invalid operator defaults to ==.
        case operator
        when '<'
          match = spell_info.select { |k,v| v['base_level'] < term.to_i }
        when '>'
          match = spell_info.select { |k,v| v['base_level'] > term.to_i }
        else
          match = spell_info.select { |k,v| v['base_level'] == term.to_i }
        end
      when 'tradition'
        match = spell_info.select { |k,v| v['tradition']&.include? term.downcase }
      when 'school'
        match = spell_info.select { |k,v| v['school']&.include? term.capitalize }
      when 'bloodline'
        match = spell_info.select { |k,v| v['bloodline']&.include? term.downcase }
      when 'cast'
        match = spell_info.select { |k,v| v['cast']&.include? term.downcase }
      when 'description', 'desc', 'effect'
        match = spell_info.select { |k,v| v['effect'].upcase.match? term.upcase }
      end

      match.keys

    end

    def self.get_spell_search_results(list)

      fmt_list = []
      list.each do |spell|
        result = get_spell_details(spell)
        name = result[0]
        details = result[1]

        fmt_list << format_spell(name, details)
      end

      fmt_list.sort

    end

    def self.format_spell(name, details)

      return t('pf2emagic.spell_details_missing', :name => name.upcase) if !details

      fmt_name = "%x172#{name}%xn"
      trait_list = details['traits'].sort
      is_uncommon = trait_list.include?('uncommon') ? "(%xyUNCOMMON%xn)" : ""
      is_rare = trait_list.include?('rare') ? "(%xh%xmRARE%xn)" : ""
      is_unique = trait_list.include?('unique') ? "(%xh%xrUNIQUE%xn)" : ""
      hard_to_get = is_uncommon + is_rare + is_unique

      traits = "%x229Traits:%xn #{trait_list.join(", ")}"

      # Grab all the small stuff and assemble into a useful string.
      actions = ("%x229Actions%xn:" + details["actions"].to_s || "").ljust(39)
      base_level = details["base_level"]
      level = ("%x229Base Level%xn:" + base_level.to_s).ljust(39)
      cast = ("%r%x229Casting%xn:" + details["cast"].join(", ")).ljust(39)
      area = ("%x229Area%xn:" + details["area"].to_s || "").ljust(39)
      range = ("%r%x229Range%xn:" + details["range"].to_s || "").ljust(39)
      save = ("%x229Save%xn:" + details["save"].to_s || "").ljust(39)
      duration = ("%r%x229Duration%xn:" + details["duration"].to_s || "").ljust(78)

      trads = details["tradition"] ? ("%r%x229Traditions%xn:" + details["tradition"].sort.join(", ") + "%r") : ""

      little_junk = actions + level + cast + area + range + save + duration + trads
      # Handle heightening processing.
      heighten = details["heighten"]
      if heighten

        h = []
        if heighten.is_a?(Hash)
          heighten.each_pair do |k,v|
            h << "#{k}: #{v}"
          end
        else
          heighten.each_with_index do |v,i|
            h << "#{i + base_level}: #{v}"
          end
        end

        h.join("%r")
      else
        h = ""
      end

      desc = "%r%x229Description:%xn #{details['effect']}"

      "#{fmt_name}%b#{hard_to_get}%r%r#{traits}%r#{little_junk}%r#{desc}%r#{h}"
    end

  end
end
