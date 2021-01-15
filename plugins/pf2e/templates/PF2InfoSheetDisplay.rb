module AresMUSH
  module Pf2e

    class SheetInfoTemplate < ErbTemplateRenderer
      include SheetInfoFields

      attr_accessor :char, :enactor, :sheet

      def initialize(char, sheet, enactor)
        @char = char
        @sheet = sheet
        @enactor = enactor
        super File.dirname(__FILE__) + "/sheet_info.erb"
      end

      def section_line(title)
        @client.screen_reader ? title : line_with_text(title)
      end

    end
  end
end
