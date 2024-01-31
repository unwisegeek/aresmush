module AresMUSH
  module Pf2noms

    class PF2RPPHistTemplate < ErbTemplateRenderer
      include CommonTemplateFields

      attr_accessor :char, :player, :paginator, :client

      def initialize(char, player, paginator, client)
        @char = char
        @player = player
        @paginator = paginator
        @client = client

        super File.dirname(__FILE__) + "/rpphist_template.erb"
      end

      def textline(title)
        @client.screen_reader ? title : line_with_text(title)
      end

      def title
        t('pf2noms.rpphist_title', :char => @char.name)
      end

      def total_rpp
        @player.total_rpp
      end

      def page_items
        @paginator.page_items
      end

      def page_footer
        @paginator.page_footer
      end

      def available_rpp
        @player.available_rpp
      end

      def header_line
        "%b%b#{item_color}#{left("Date", 20)}%b%b#{left("Awarder", 15)}%b%b#{left("Award", 8)}%b%b#{left("Reason", 35)}"
      end

      def time(item)
        converted_time = Time.at(item[0])

        OOCTime.local_short_timestr(@char, converted_time)
      end

      def char(item)
        item[1]
      end

      def award(item)
        item[2].to_s
      end

      def reason(item)
        item[3]
      end

    end
  end
end
