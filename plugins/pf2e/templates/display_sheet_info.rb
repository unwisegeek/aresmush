module AresMUSH
  module Pf2e

    class SheetInfoTemplate < ErbTemplateRenderer
      include CommonTemplateFields

      attr_accessor :char, :enactor, :sheet

      def initialize(char, sheet, client)
        @char = char
        @sheet = sheet
        @client = client
        super File.dirname(__FILE__) + "/sheet_info.erb"
      end

      def section_line(title)
        @client.screen_reader ? title : line_with_text(title)
      end

      def name
        @char.name
      end

      def base_info_fields
        @sheet.pf2_base_info
      end

      def level
        @sheet.pf2_level
      end

      def xp
        @sheet.pf2_xp
      end

    end
  end
end
