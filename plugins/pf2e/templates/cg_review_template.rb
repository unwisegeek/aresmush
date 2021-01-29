module AresMUSH
  module Pf2e

    class PF2CGReviewDisplay < ErbTemplateRenderer
      include CommonTemplateFields

      attr_accessor :char, :client

      def initialize(char, client)
        @char = char
        @client = client

        super File.dirname(__FILE__) + "/cg_review.erb"
      end

      def elements
        base_info = @char.pf2_base_info
        @ancestry = base_info[:ancestry]
        @heritage = base_info[:heritage]
        @background = base_info[:background]
        @charclass = base_info[:charclass]
        @subclass = base_info[:specialize]

        @ancestry_info = @ancestry.blank? ? "" : Global.read_config('pf2e_ancestry', @ancestry)
        @heritage_info = @heritage.blank? ? "" : Global.read_config('pf2e_heritage', @heritage)
        @background_info = @background.blank? ? "" : Global.read_config('pf2e_background', @background)
        @charclass_info = @charclass.blank? ? "" : Global.read_config('pf2e_class', @charclass)
      end

      def name
        @char.name
      end

      def ancestry
        @ancestry.blank? ? nil : @ancestry
      end

      def heritage
        @heritage.blank? ? nil :@heritage
      end

      def background
        @background.blank? ? nil :@background
      end

      def charclass
        @charclass.blank? ? nil :@charclass
      end

      def subclass
        @subclass.blank? ? nil :@subclass
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
        list = @background_info["req_abl_boosts"]
        list.empty? "None required." : list.join(" or ")
      end

      def free_bg_boosts
        @background_info["abl_boosts_open"]
      end

      def charclass_boosts
        list = @charclass_info["key_score"]
        list.join("or")
      end

      def specials
        specials = @ancestry_info["special"] + @heritage_info["special"] + @background_info["special"].flatten!
        if Pf2e.character_has?(@ancestry_info["special"], "Low-Light Vision") && @heritage == "Dar"
          specials = specials.delete_at specials.index("Low-Light Vision") + [ "Darkvision" ]
        end
        specials.empty? ? "No special abilities or senses." : specials.sort.join(", ")
      end
    end

  end
end
