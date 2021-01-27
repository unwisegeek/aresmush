module AresMUSH
  module Pf2e

    class PF2CGReviewDisplay < ErbTemplateRenderer
      include CommonTemplateFields

      attr_accessor :char, :sheet, :ancestry, :background, :charclass, :heritage

      def initialize(char, sheet, ancestry=nil, heritage=nil, background=nil, charclass=nil)
        @char = char
        @sheet = sheet
        @ancestry = ancestry
        @heritage = heritage
        @background = background
        @charclass = charclass

        super File.dirname(__FILE__) + "/cg_review.erb"
      end

      def element_info
        self.ancestry_info = @ancestry ? Global.read_config('pf2e_ancestry', @ancestry) : nil
        self.heritage_info = @heritage ? Global.read_config('pf2e_heritage', @heritage) : nil
        self.background_info = @background ? Global.read_config('pf2e_background', @background) : nil
        self.charclass_info = @charclass ? Global.read_config('pf2e_class', @charclass) : nil
      end

      def section_line(title)
        @client.screen_reader ? title : line_with_text(title)
      end

      def name
        @char.name
      end

      def ancestry
        @ancestry ? @ancestry : nil
      end

      def heritage
        @heritage ? @heritage : nil
      end

      def background
        @background ? @background : nil
      end

      def charclass
        @charclass ? @charclass : nil
      end

      def hp
        self.ancestry_info["HP"] + self.class_info["HP"]
      end

      def size
        self.ancestry_info["Size"]
      end

      def speed
        self.ancestry_info["Speed"]
      end

      def open_boosts
        self.ancestry_info["abl_boosts_open"] + self.background_info["abl_boosts_open"] + 4
      end

      def ancestry_boosts
        self.ancestry_info["abl_boosts"]
      end

      def background_boosts
        list = self.background_info["req_abl_boosts"]
        list.empty? ? "None required." : list.join(" or ")
      end

      def charclass_boosts
        list = self.charclass_info["key_score"]
        list.join("or")
      end

      def specials
        specials = self.ancestry_info["special"] + self.heritage_info["special"] + self.background_info["special"].flatten!
        if Pf2e.character_has?(specials, "Low-Light Vision") && @heritage == "Dar"
          specials = specials.delete_at specials.index("Low-Light Vision") + ["Darkvision"]
        end
        specials.empty? ? "No special abilities or senses." : specials.sort.join(", ")
      end

    end
  end
end
