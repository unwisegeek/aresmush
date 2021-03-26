module AresMUSH
  module Pf2e

    class Pf2eRollAliasTemplate < ErbTemplateRenderer
      include CommonTemplateFields

      attr_accessor :char, :list

      def initialize(char, list)
        @char = char
        @list = list

        super File.dirname(__FILE__) + "/rollalias.erb"
      end

      def title
        t('pf2e.rollalias_title', :name => @char.name)
      end

      def alias_list
        fmt_list = []

        @list.each_pair do |key, value|
          fmt_list << format_alias(key, value)
        end

        fmt_list
      end

      def header_row
        "#{left('%xhAlias%xn', 26)}#{left("%xhValue%xn", 52)}"
      end

      def format_alias(rollalias, value)
        fmt_a = "#{item_color}" + "#{rollalias}"

        "#{left(fmt_a, 26)}#{left(value, 52)}%r"
      end
    end
  end
end
