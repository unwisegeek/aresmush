module AresMUSH
  module Pf2e

    class Pf2eSheetTemplate < ErbTemplateRenderer
      include CommonTemplateFields

      attr_accessor :char, :section, :client, :base_info, :faith_info

      def initialize(char, section, client, base_info, faith_info)
        @char = char
        @section = section
        @client = client
        @base_info = base_info
        @faith_info = faith_info

        super File.dirname(__FILE__) + "/sheet_template.erb"
      end

      def section_line(title)
        @client.screen_reader ? title : line_with_text(title)
      end

      def section
        @section
      end

      def subclass_list
        Global.read_config('pf2e', 'subclass_names')
      end

      def name
        @char.name
      end

      def ancestry
        @base_info['ancestry']
      end

      def heritage
        @base_info['heritage']
      end

      def background
        @base_info['background']
      end

      def charclass
        @base_info['charclass']
      end

      def subclass
        @base_info['specialize'] ? @base_info['specialize'] : "N/A"
      end

      def subclass_name
        subclass_list[charclass] ? subclass_list[charclass] : "Specialty"
      end

      def subclass_option
        @base_info['specialize_info'].blank? ?
                  "" :
                  "/" + @base_info['specialize_info']
      end

      def traits
        @char.pf2_traits.sort.join(", ")
      end

      def level
        @char.pf2_level
      end

      def xp
        @char.pf2_xp
      end

      def faith
        @char.group('Faith')
      end

      def region
        @char.group('Region')
      end

      def deity
        @faith_info['deity']
      end

      def alignment
        @faith_info['alignment']
      end

      def has_code
        if (@faith_info['edicts']) || (@faith_info['anathema'])
          t('pf2e.has_code')
        end
      end

      def abilities
        abil_list = @char.abilities

        return [] if !abil_list

        list = []
        abil_list.each_with_index do |a,i|
          name = a.name
          score = a.mod_val ? a.mod_val : a.base_val
          list << format_ability(name, score, i)
        end

        list
      end

      def skills
        skills = @char.skills

        return [] if skills.empty?

        sort_skills = skills.to_a.sort_by { |s| s.name }

        list = []
        sort_skills.each_with_index do |s,i|
          list << format_skill(@char, s, i)
        end

        list
      end

      def lores
        lores = @char.lores

        return [] if lores.empty?

        list = []
        lores.each_with_index do |lore,i|
          list << format_lore(@char, lore, i)
        end

        list
      end

      def hp
        hp = @char.hp

        return "---" if !hp

        current = Pf2eHP.get_current_hp(@char)
        max = Pf2eHP.get_max_hp(@char)
        percent = max.zero? ? 0 : (current / max) * 100.floor
        hp_color = "%xg" if percent > 75
        hp_color = "%xc" if percent.between?(50,75)
        hp_color = "%xy" if percent.between?(25,50)
        hp_color = "%xr" if percent < 25
        "#{hp_color}#{current}%xn / #{max} (#{percent}%)"
      end

      def temp_hp
        hp = @char.hp

        return "---" if !hp

        has_temp_hp = hp.temp_max

        return "None." if !has_temp_hp

        current = hp.temp_current
        max = hp.temp_max
        "#{current}%xn / #{max}"
      end

      def class_dc
        return "--" if !combat_stats
        dc = Pf2eCombat.get_class_dc(@char)
        prof = combat_stats.class_dc[0].upcase
        "#{dc} (#{prof})"
      end

      def perception
        return "--" if !combat_stats
        bonus = Pf2eCombat.get_perception(@char)
        prof = combat_stats.perception[0].upcase
        "#{bonus} (#{prof})"
      end

      def saves
        saves = %w{fortitude reflex will}
        list = []
        saves.each do |s|
          list << format_save(@char, s)
        end

        list
      end

      def specials
        @char.pf2_special.sort.join(", ")
      end

      def conditions
        cond = @char.pf2_conditions
        if cond.empty?
          value = "None active."
        else
          list = []
          cond.each do |c,v|
            list << format_condition(c,v)
          end

          value = list.sort.join(", ")
        end

        value
      end

      def feats
        charclass_list = @char.pf2_feats['charclass']
        ancestry_list = @char.pf2_feats['ancestry']
        general_list = @char.pf2_feats['general']
        skill_list = @char.pf2_feats['skill']

        charclass_list = charclass_list.map { |f| f + " (CL)" }
        ancestry_list = ancestry_list.map { |f| f + " (AN)" }
        general_list = general_list.map { |f| f + " (GN)" }
        skill_list = skill_list.map { |f| f + " (SK)" }

        feats = charclass_list + ancestry_list + general_list + skill_list
      end

      def features
        flist = @char.pf2_features.sort.join(", ")
      end

      def dedication_feats
        list = @char.pf2_feats['dedication'].sort.join(", ")
      end

      def languages
        lang = @char.pf2_lang
        list = lang.empty? ? "None set." : lang.sort.join(", ")
      end

      def spell_dcs
        dc_list = magic_stats.tradition

        list = []

        dc_list.each_pair do |charclass, dc|
          list << format_spell_dc(charclass, dc[0], dc[1])
        end

        list.join("%r")
      end

      def combat_stats
        @char.combat
      end

      def magic_stats
        @char.magic
      end

      def format_ability(abil, score, i)
        name = "#{item_color}#{abil.capitalize}%xn"
        linebreak = i % 3 == 0 ? "%r" : ""
        mod = "(#{Pf2eAbilities.abilmod(score)})"
        "#{linebreak}#{left(name, 13)}: #{left(score, 2)} #{left(mod, 9)}"
      end

      def format_condition(condition, value)
        colors = Global.read_config('pf2e', 'condition_colors')
        cond_color = colors[condition.to_s]
        name = "#{cond_color}#{condition.to_s.capitalize!}"
        value = value ? "%b#{value}" : ""
        "#{name}#{value}%xn"
      end

      def format_skill(char, s, i)
        name = s.name
        fmt_name = "#{item_color}#{name}%xn"
        linked_attr = print_linked_attr(name)
        skill_mod = "%xh#{Pf2eSkills.get_skill_bonus(char, name)}%xn"
        linebreak = i % 2 == 1 ? "" : "%r"
        proflevel = " (#{s.prof_level[0].upcase})"
        "#{linebreak}#{left(fmt_name + linked_attr,21)} #{left(skill_mod + proflevel, 17)}"
      end

      def format_lore(char,lore, i)
        name = lore.name
        fmt_name = "#{item_color}#{name}%xn"
        linked_attr = " %xh%xx(INT)%xn"
        lore_mod = "%xh#{Pf2eLores.get_lore_bonus(char, name)}%xn"
        linebreak = i % 2 == 1 ? "" : "%r"
        proflevel = " (#{lore.prof_level[0].upcase})"
        "#{linebreak}#{left(fmt_name + linked_attr,21)} #{left(lore_mod + proflevel, 17)}"
      end

      def format_save(char,name)
        save = "#{item_color}#{name.capitalize}%xn"
        prof = Pf2eCombat.get_save_from_char(char, name)
        bonus = Pf2eCombat.get_save_bonus(char, name)
        "#{left("#{save}: #{bonus} (#{prof[0].upcase})", 26)}"
      end

      def format_spell_dc(c, t, p)
        dc = Pf2eMagic.get_spell_dc(char, c, p)
        trad = Pf2e.pretty_string(t)
        atk = dc - 10

        "#{item_color}#{c}: Tradition - #{trad} Spell Attack Roll: #{atk} Spell DC: #{dc}"
      end

      def print_linked_attr(skill)
        apt = Pf2eSkills.get_linked_attr(skill)
        " %xh%xx(#{apt[0..2].upcase})%xn"
      end

    end
  end
end
