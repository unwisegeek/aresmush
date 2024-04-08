module AresMUSH
  module Pf2e
    class PF2CGInfoTemplate < ErbTemplateRenderer
      include CommonTemplateFields

      attr_accessor :paginator

      def initialize(paginator)
        @paginator = paginator

        super File.dirname(__FILE__) + "/cg_info.erb"
      end

      def title
        "Available Options"
      end

      def cg_info_list
        list = []

        @paginator.page_items.each_with_index do |item, i|
          list << format_cginfo_options(item, i)
        end

        list
      end

      def format_cginfo_options(item, i)
        linebreak = i % 2 == 0 ? "%r" : ""

        "#{linebreak}#{left(string, 37)}%b"
      end

    end
  end
end
