module AresMUSH
  module Pf2egear

    class Pf2eDisplayItemTemplate < ErbTemplateRenderer
      include CommonTemplateFields

      attr_accessor :char, :item, :client, :category

      def initialize(char, item, category, client)
        @char = char
        @item = item
        @category = category
        @client = client

        super File.dirname(__FILE__) + "/display_item.erb"
      end

      def section_line(title)
        @client.screen_reader ? title : line_with_text(title)
      end

      def title
        name = @item.nickname ? "#{@item.nickname} (#{@item.name})" : @item.name

        t('pf2egear.item_view_title', :name => name)
      end

      def bulk
        b = @item.bulk

        b == 0.1 ? "L" : b.to_i
      end

      def traits
        @item.traits.sort.join(", ")
      end

      def level
        @item.level
      end

      def sell_price
        Pf2egear.display_money(@item.price / 2)
      end

      def item_info

        return [ "Item info goes here based on type. This is a #{@category}." ]

        list_to_format = {}

        fmt_list = []

        case @category 
        when "weapon", "weapons"
        when "armor"
        when "magicitem"
        when "shield", "shields"
        end

        fmt_list 

      end

      def magical_properties

        if @category == "magicitem"

          return [ "Properties for magic items, like uses and investments and whether it's a consumable." ]
          
        elsif @category == ("shield" || "shields")
          
          return [ "Shields don't have magical properties, but an attached weapon such as a shield boss can. This will hold information on attached weapons / properties." ]

        else

          list = []

          talismans = format_talismans(@item.talisman)
          fund_runes = format_fund_runes(@item.runes["fundamental"])
          prop_runes = format_prop_runes(@item.runes["property"])

          list << talismans
          list << "#{item_color}Runes:%xn"
          list << fund_runes
          list << prop_runes

          list.join("%r")
        end

      end

      def format_talismans(talismans)
        "#{item_color}Talismans:%xn #{talismans.sort.join(",")}"
      end

      def format_fund_runes(runes)
        "%t%xh%xwFundamental:%xn #{runes}"
      end

      def format_prop_runes(runes)
        "%t%xh%xwProperty:%xn #{runes}"
      end

    end

  end
end
