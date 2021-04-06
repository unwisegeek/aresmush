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
        abilities = @char.abilities

        return [] if !abilities

        list = []
        abilities.each_with_index do |a,i|
          name = a.name
          score = a.mod_val ? a.mod_val : a.base_val
          list << format_ability(name, score, i)
        end
        list
      end

      def skills
        skills = @char.skills

        return [] if skills.empty?

        list = []
        skills.each_with_index do |s,i|
          list << format_skill(s, i)
        end
      end

      def lores
        lores = @char.lores

        return [] if lores.empty?

        list = []
        lores.each_with_index do |lore,i|
          list << format_lore(lore, i)
        end
      end

      def combat_stats
        @char.combat
      end

      def hp
        hp = @char.hp

        return "---" if !hp

        current = hp.current
        max = hp.max_current
        low_max = max != hp.max_base ? "%xy*%xn" : ""
        percent = max.zero? ? 0 : (current / max) * 100.floor
        hp_color = "%xg" if percent > 75
        hp_color = "%xc" if percent.between?(50,75)
        hp_color = "%xy" if percent.between?(25,50)
        hp_color = "%xr" if percent < 25
        "#{hp_color}#{current}%xn / #{max}#{low_max} (#{percent})"
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
        "#{bonus} (#{prof})"
      end

      def perception
        return "--" if !combat_stats
        bonus = Pf2eCombat.get_perception(@char)
        prof = combat_stats.perception[0].upcase
        "#{bonus} (#{prof})"
      end

      def saves
        saves = %w{Fortitude Reflex Will}
        list = []
        saves.each do |save|
          list << format_save(@char, save)
        end
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

        feats = charclass_list + ancestry_list + general_list + skill_list

        list = []

        feats.each_with_index { |f,i| list << format_feat(f,i) }

        list
      end

      def dedication_feats
        list = @char.pf2_feats['dedication'].sort.join(", ")
      end

      def format_ability(abil, score, i)
        name = "%xh#{abil.capitalize!}%xn:"
        linebreak = i % 3 == 0 ? "%r" : ""
        mod = "(#{Pf2eAbilities.get_ability_mod(score)})"
        "#{linebreak}#{left(name, 10)}: #{left(score, 3)} #{left(mod, 13)}"
      end

      def format_condition(condition, value)
        colors = Global.read_config('pf2e', 'condition_colors')
        cond_color = colors[condition.to_s]
        name = "#{cond_color}#{condition.to_s.capitalize!}"
        value = value ? "%b#{value}" : ""
        "#{name}#{value}%xn"
      end

      def format_skill(s, i)
        name = s.name
        fmt_name = "%xh#{name}:%xn"
        linked_attr = print_linked_attr(name)
        linebreak = i % 2 == 1 ? "" : "%r"
        proflevel = "#{s.proflevel}#{linked_attr}"
        "#{linebreak}#{left(name, 18)} #{left(proflevel, 18)}"
      end

      def format_lore(lore, i)
        name = lore.name
        fmt_name = "%xh#{name}:%xn"
        linked_attr = "INT"
        linebreak = i % 2 == 1 ? "" : "%r"
        proflevel = "#{s.proflevel}#{linked_attr}"
        "#{linebreak}#{left(name, 18)} #{left(proflevel, 18)}"
      end

      def format_save(char, save)
        name = "#{save.capitalize!}"
        prof = "#{Pf2eCombat.get_save_from_char(char, save)}"[0].upcase
        bonus = Pf2eCombat.get_save_bonus(char, save)
        left("#{item_color}#{name}%xn: #{bonus} (#{prof})", 26)
      end

      def format_feat(name, index)
        linebreak = index % 3 == 0 ? "%r" : ""
        "#{linebreak}#{left(name, 26)}"
      end

      def print_linked_attr(skill)
        apt = Pf2eSkills.get_linked_attr(skill.name)
        !apt ? "" : " %xh%xx(#{apt[0..2].upcase})%xn"
      end

    end
  end
end
