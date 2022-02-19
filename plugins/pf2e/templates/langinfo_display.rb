module AresMUSH
  module Pf2e
    class PF2LanguageInfoTemplate < ErbTemplateRenderer
      include CommonTemplateFields

      attr_accessor :language_list, :language_type

      def initialize(language_list,  language_type)
        @language_list = language_list
        @language_type = language_type

        super File.dirname(__FILE__) + "/langinfo_display.erb"
      end

      def title
        type = @language_type.capitalize

        title = "#{type}"
      end

      def langs
        list = []

        @language_list.each_pair do |lang,desc|
          list << format_language(lang, desc)
        end

        list
      end

      def format_language(lang, desc)
        "#{item_color}#{lang}%xn: #{desc}"
      end

    end
  end
end
