module AresMUSH
  module Pf2e
    class PF2FormulaTemplate < ErbTemplateRenderer
      include CommonTemplateFields

      attr_accessor :char, :result

      def initialize(result, char=nil)
        @char = char
        @result = result

        super File.dirname(__FILE__) + "/formulas.erb"
      end

      def title
        @char ? t('pf2e.formula_char_title', :char => @char.name) : 
                t('pf2e.formula_disp_title')
      
      end

      def formulas
        list = []

        @result.each_pair do |key, values|
          header = "%r%r#{item_color}#{key.upcase}%xn:%r"
          fmt_list = []
          values.each_with_index do |item, i|
            fmt_list << format_formulas(item, i)
          end

          list << [header, fmt_list]
        end

        list.flatten
      end

      def format_formulas(name, i)
        linebreak = i % 3 == 0 ? "" : "%r"

        "#{linebreak}%b%b#{left(name,24)}"
      end

    end
  end
end