module AresMUSH
  module Pf2e

    class PF2CNoteTemplate < ErbTemplateRenderer
      include CommonTemplateFields

      attr_accessor :char, :cnotes, :client

      def initialize(char, cnotes, client)
        @char = char
        @cnotes = cnotes
        @client = client

        super File.dirname(__FILE__) + "/cnote_display.erb"
      end

      def title
        t('pf2e.cnotes_title', :char => @char.name)
      end

      def cnote_list
        list = []

        @cnotes.each_pair do |name, note|
          list << "#{item_color}#{name}:%xn%r%r#{note}"
        end

        list
      end

    end
  end
end
