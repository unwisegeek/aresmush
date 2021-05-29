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

      def textline(title)
        @client.screen_reader ? title : line_with_text(title)
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
        return nil if !@target
        @target.split(",").map { |w| Pf2e.pretty_string(w) }.sort.join(", ")
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

      def damage_type
        @details["damage_type"]
      end

      def save
        @details["save"]
      end

      def save_dc
        magic = @caster.magic
        spell_abil = magic.spell_abil[@tradition]
        spell_prof = magic.spell_prof
        prof_bonus = Pf2e.get_prof_bonus(@caster, spell_prof)

        abil_mod = Pf2eAbilities.get_ability_mod(
          Pf2eAbilities.get_ability_score @caster, spell_abil
        )

        dc = 10 + abil_mod + prof_bonus
      end

    end
  end
end
