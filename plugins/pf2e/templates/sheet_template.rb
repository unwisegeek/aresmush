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
        @base_info[:ancestry]
      end

      def heritage
        @base_info[:heritage]
      end

      def background
        @base_info[:background]
      end

      def charclass
        @base_info[:charclass]
      end

      def subclass
        @base_info[:specialize] ? @base_info[:specialize] : "N/A"
      end

      def subclass_name
        subclass_list[charclass] ? subclass_list[charclass] : "Specialty"
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
        @faith_info[:faith]
      end

      def deity
        @faith_info[:deity]
      end

      def alignment
        @faith_info[:alignment]
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
        cond = @char.pf2_conditions
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
        "#{linebreak}#{left(name, 16)}: #{left(score, 3)} #{left(mod, 20)}"
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
