module AresMUSH
  module Pf2e

    class Pf2eSheetTemplate < ErbTemplateRenderer
      include CommonTemplateFields

      attr_accessor :char, :sheet, :client

      def initialize(char, sheet, section, client)
        @char = char
        @sheet = sheet
        @section = section
        @client = client
        super File.dirname(__FILE__) + "/sheet_template.erb"
      end

      def section_line(title)
        @client.screen_reader ? title : line_with_text(title)
      end

      def section
        @section
      end

      def base_info
        self.base_info = @sheet.pf2_base_info
        self.faith_info = @sheet.pf2_faith
      end

      def subclass_list
        Global.read_config('pf2e', 'subclass_names')
      end

      def name
        @char.name
      end

      def ancestry
        self.base_info[:ancestry]
      end

      def heritage
        self.base_info[:heritage]
      end

      def background
        self.base_info[:background]
      end

      def charclass
        self.base_info[:charclass]
      end

      def subclass
        self.base_info[:specialize] ? self.base_info[:specialize] : "N/A"
      end

      def subclass_name
        subclass_list[charclass] ? subclass_list[charclass] : "Specialty"
      end

      def traits
        @sheet.pf2_traits.sort.join(", ")
      end

      def level
        @sheet.pf2_level
      end

      def xp
        @sheet.pf2_xp
      end

      def faith
        self.faith_info[:faith]
      end

      def deity
        self.faith_info[:deity]
      end

      def abilities
        abilities = @char.abilities
        list = []
        abilities.each do |a|
          name = a.name
          score = a.mod_val ? a.mod_val : a.base_val
          list << format_ability(name, score)
        end
        list
      end

      def conditions
        cond = @sheet.pf2_conditions
        if cond.empty?
          list = "None active."
        else
          list = []
          cond.each do |c,v|
            list << format_condition(c,v)
          end
        end
        list.sort.join(", ")
      end

      def format_ability(abil, score)
        name = "%xh#{abil.capitalize}%xn:"
        linebreak = i % 2 == 1 ? "" : "%r"
        mod = "(#{Pf2e.get_ability_mod(score)})"
        "#{linebreak}#{left(name, 16)}: #{left(score, 3)} #{left(mod, 20)} "
      end

      def format_condition(condition, value)
        colors = Global.read_config('pf2e', 'condition_colors')
        cond_color = colors[condition.to_s]
        name = "#{cond_color}#{condition.to_s.capitalize}"
        value = value ? "%b#{value}" : ""
        "#{name}#{value}%xn"
      end

      # Copied from FS3, fix for PF2 when ready
      def format_skill(s, i, show_linked_attr = false)
        name = "%xh#{s.name}:%xn"
        linked_attr = show_linked_attr ? print_linked_attr(s) : ""
        linebreak = i % 2 == 1 ? "" : "%r"
        rating_text = "#{s.rating_name}#{linked_attr}"
        "#{linebreak}#{left(name, 14)} #{left(s.print_rating, 8)} #{left(rating_text, 16)}"
      end

      # Copied from FS3, fix for PF2 when ready
      def print_linked_attr(skill)
        apt = FS3Skills.get_linked_attr(skill.name)
        !apt ? "" : " %xh%xx(#{apt[0..2].upcase})%xn"
      end


    end
  end
end
