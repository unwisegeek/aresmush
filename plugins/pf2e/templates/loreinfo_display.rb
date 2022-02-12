module AresMUSH
  module Pf2e
    class PF2LoreInfoTemplate < ErbTemplateRenderer
      include CommonTemplateFields

      attr_accessor :lore_list, :lore_type

      def initialize(lore_list, lore_type)
        @lore_list = lore_list
        @lore_type = lore_type

        super File.dirname(__FILE__) + "/loreinfo_display.erb"
      end

      def title
        type = @lore_type.capitalize

        title = "Available Lores For Type #{type}"

        if type == "All"
          title = "Emblem of Ea Available Lores"
        end

        title
      end

      def lores

        list = []

        @lore_list.each_with_index do |lore,i|
          list << format_lore(lore, i)
        end

        list
      end

      def format_lore(lore, i)
        linebreak = i % 3 == 0 ? "" : "%r"
        "#{linebreak}#{left(lore, 25)}"
      end

    end
  end
end
