module AresMUSH
  module Pf2e

    class PF2CGTestDisplay < ErbTemplateRenderer
      include CommonTemplateFields

      attr_accessor :char, :client

      def initialize(char, client)
        @char = char
        @client = client

        base_info = @char.pf2_base_info
        @ancestry = base_info['ancestry']
        @heritage = base_info['heritage']
        @background = base_info['background']
        @charclass = base_info['charclass']
        @subclass = base_info['specialize']

        @ancestry_info = @ancestry.blank? ? {} : Global.read_config('pf2e_ancestry', @ancestry)
        @heritage_info = @heritage.blank? ? {} : Global.read_config('pf2e_heritage', @heritage)
        @background_info = @background.blank? ? {} : Global.read_config('pf2e_background', @background)
        @charclass_info = @charclass.blank? ? {} : Global.read_config('pf2e_class', @charclass)
        @faith_info = @char.pf2_faith

        super File.dirname(__FILE__) + "/cgtest.erb"
      end

      def section_line(title)
        @client.screen_reader ? title : line_with_text(title)
      end

      def name
        @char.name
      end

      def ancestry
        @ancestry
      end

      def heritage
        @heritage
      end

      def background
        @background
      end

      def charclass
        @charclass
      end

      def subclass
        @subclass
      end

      def faith
        @faith_info['faith']
      end

      def deity
        @faith_info['deity']
      end

      def alignment
        @faith_info['alignment']
      end

      def ancestry_info
        @ancestry_info
      end

      def heritage_info
        @heritage_info
      end

      def background_info
        @background_info
      end

      def charclass_info
        @charclass_info
      end

      def ahp
        @ancestry_info["HP"]
      end


    end
  end
end
