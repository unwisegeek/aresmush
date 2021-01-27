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

        @ancestry_info = @ancestry.blank? ? Global.read_config('pf2e_ancestry', @ancestry) : nil
        @heritage_info = @heritage.blank? ? Global.read_config('pf2e_heritage', @heritage) : nil
        @background_info = @background.blank? ? Global.read_config('pf2e_background', @background) : nil
        @charclass_info = @charclass.blank? ? Global.read_config('pf2e_class', @charclass) : nil
      end

      def name
        @char.name
      end

      def ancestry
        @ancestry.blank? ? @ancestry : nil
      end

      def heritage
        @heritage.blank? ? @heritage : nil
      end

      def background
        @background.blank? ? @background : nil
      end

      def charclass
        @charclass.blank? ? @charclass : nil
      end

      def charclass
        @charclass ? @charclass : nil
      end

      def hp
        @ancestry_info["HP"] + self.charclass_info["HP"]
      end

      def size
        @ancestry_info["Size"]
      end

      def speed
        @ancestry_info["Speed"]
      end

      def traits
        @ancestry_info["traits"] + @heritage_info["traits"] + [ @charclass ].uniq.sort.join(", ")
      end

      def ancestry_boosts
        @ancestry_info["abl_boosts"]
      end

      def free_ancestry_boosts
        @ancestry_info["abl_boosts_open"]
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
        specials = @ancestry_info["special"] + @heritage_info["special"] + @background_info["special"].flatten!
        if Pf2e.character_has?(specials, "Low-Light Vision") && @heritage == "Dar"
          specials = specials.delete_at specials.index("Low-Light Vision") + [ "Darkvision" ]
        end
        specials.empty? ? "No special abilities or senses." : specials.sort.join(", ")
      end

    end
  end
end
