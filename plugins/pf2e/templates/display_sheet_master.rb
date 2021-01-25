module AresMUSH
  module Pf2e

    class MasterSheetTemplate < ErbTemplateRenderer
      include CommonTemplateFields

      attr_accessor :char, :enactor, :sheet

      def initialize(char, sheet, client)
        @char = char
        @sheet = sheet
        @client = client
        super File.dirname(__FILE__) + "/sheet_master.erb"
      end



    end
  end
end
