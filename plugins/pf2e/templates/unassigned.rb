module AresMUSH
  module Pf2e

    class Pf2eUnassignedTemplate < ErbTemplateRenderer
      include CommonTemplateFields

      attr_accessor :char, :to_assign

      def initialize(char, to_assign)
        @char = char
        @to_assign = to_assign

        super File.dirname(__FILE__) + "/unassigned.erb"
      end

      def title
        t('pf2e.unassigned_title', :name => @char.name)
      end

      def to_assign
        list = []

        @to_assign.each_pair do |key, value|
          list << format_option(key, value)
        end

        list
      end

      def format_option(element, options)
        title_e = element.split.each { |word| word.capitalize }.join
        fmt_e = "#{title_e} : "
        fmt_o = options.is_a?(Array) ? options.join(" or ") : options

        "%b%b%b#{item_color}#{fmt_e}#{fmt_o}%r"
      end
    end
  end
end
