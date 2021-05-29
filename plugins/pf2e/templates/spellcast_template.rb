module AresMUSH
  module Pf2e

    class Pf2eCastSpellTemplate < ErbTemplateRenderer
      include CommonTemplateFields

      attr_accessor :caster, :spell, :tradition, :level, :target

      def initialize(caster, spell, tradition, level, target)
        @caster = caster
        @spell = spell
        @tradition = tradition
        @level = level
        @target = target

        @details = Global.read_config('pf2e_spells', spell)

        super File.dirname(__FILE__) + "/spellcast_template.erb"
      end

      def caster_name
        @caster.name
      end

      def spell
        @spell
      end

      def cast_tradition
        @tradition
      end

      def cast_level
        @level
      end

      def target
        @target
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

      def damage
        d = @details["damage"]

        return nil if !d

        heighten = @level - base_level

        damage = d.is_a?(Array) ? d[heighten] : d
      end

      def dam_roll
        return nil if !damage
        return damage if !(damage.match? "d")

        roll = Pf2e.parse_roll_string(@caster, damage)

        roll["total"]
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
