module AresMUSH
  module Pf2emagic
    class PF2DisplayPreparedSpellsTemplate < ErbTemplateRenderer
      include CommonTemplateFields

      attr_accessor :char, :spell_list

      def initialize(char, spell_list)
        @char = char
        @spell_list = spell_list

        super File.dirname(__FILE__) + "/prepared.erb"

      end

      def title
        t('pf2emagic.prepared_spells_title', :name => @char.name)
      end

      def spells_per_day
        @char.magic.spells_per_day
      end

      def spells

        list = []

        @spell_list.each_pair do |charclass, spells|

          sorted_spells = Pf2emagic.sort_level_spell_list(spells)
          daily_spells_for_charclass = spells_per_day[charclass]

          sublist = []
          sublist << format_level_list(daily_spells_for_charclass, sorted_spells)

          list << format_class_spell_list(charclass, sublist)
        end

        list
      end

      def format_class_spell_list(char, charclass, spells)

      end

      def format_level_list(daily_spells, spells)
        # Spells comes to this function as a hash, where the key is the level and the spell list is an array.
        list = []

        spells.each_pair do |level, list|
          max_for_level = daily_spells[level]

          list << "#{item_color}#{level}%xn (max #{max_for_level}): #{list.sort.join}"
        end

        list
      end
    end
  end
end
