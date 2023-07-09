module AresMUSH
  module Pf2e

    class Pf2eDisplaySpellTemplate < ErbTemplateRenderer
      include CommonTemplateFields

      attr_accessor :spell

      def initialize(spell)
        @spell = spell

        @details = Global.read_config('pf2e_spells', spell)

        super File.dirname(__FILE__) + "/spelldisplay_template.erb"
      end

      def spell
        @spell
      end

      def actions
        @details["actions"]
      end

      def cast
        @details["cast"].join(", ")
      end

      def area
        @details["area"]
      end

      def range
        @details["range"]
      end

      def duration
        @details["duration"]
      end

      def heighten
        string = @details["heighten"]

        return nil if !string

        h = []

        if string.is_a?(Hash)
          string.each_pair do |k,v|
            h << "#{k}: #{v}"
          end
        else
          string.each_with_index do |v,i|
            h << "#{i + base_level}: #{v}"
          end
        end

        h.join("%r")

      end

      def base_level
        @details["base_level"]
      end

      def trads
        t = @details["tradition"]

        trads = t.is_a?(Array) ? t.join(", ") : t
      end

      def effect
        @details["effect"]
      end

      def save
        @details["save"]
      end

    end
  end
end
