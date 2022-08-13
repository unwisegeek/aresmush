module AresMUSH
  module Pf2egear

    class Pf2eDisplayItemTemplate < ErbTemplateRenderer
      include CommonTemplateFields

      attr_accessor :char, :item, :client

      def initialize(char, item, client)
        @char = char
        @item = item
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
        Pf2egear.display_money(@item.price / 2).to_i
      end

      def talisman
        t = @item.talisman

        return false if !t

        t.empty? ? t.sort.join(", ") : "None attached."
      end
    end

  end
end
