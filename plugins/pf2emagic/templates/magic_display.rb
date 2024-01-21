module AresMUSH
  module Pf2emagic

    class PF2MagicDisplayTemplate < ErbTemplateRenderer
      include CommonTemplateFields

      attr_accessor :char, :client, :magic

      def initialize(char, magic, client)
        @char = char
        @client = client
        @magic = magic

        super File.dirname(__FILE__) + "/magic_display.erb"
      end

      def name
        @char.name
      end

      def textline(title)
        @client.screen_reader ? title : line_with_text(title)
      end

      def spell_details_by_charclass
        tradition = @magic.tradition

        charclass_list = tradition.keys.sort

        spells_today = @magic.spells_today

        list = []

        charclass_list.each do |charclass|
          trad_info = tradition[charclass]

          caster_type = Pf2emagic.get_caster_type(charclass)

          if caster_type == 'prepared'
            spell_list = spells_today[charclass]

            list << format_prepared_spells(@char, charclass, spell_list, trad_info)
          elsif caster_type == 'spontaneous'
            spell_list = spells_today[charclass]

            list << format_spont_spells(@char, charclass, spell_list, trad_info)
          else next
          end
        end

        list

      end

      def has_focus_spells
        focus_spells = @magic.focus_spells
        focus_cantrips = @magic.focus_cantrips

        !((focus_spells.keys + focus_cantrips.keys).empty?)
      end

      def focus_spells 
        tradition = @magic.tradition

        fstype_to_cc = Global.read_config('pf2e_magic', 'focus_type_by_class').invert

        focus_spells = @magic.focus_spells
        focus_cantrips = @magic.focus_cantrips

        fs = (focus_spells.keys + focus_cantrips.keys).uniq.sort

        list = []
        fs.each do |fs|
          charclass = fstype_to_cc[fs]
          trad_info = tradition[charclass]
          spell_list = focus_spells[fs]
          cantrip_list = focus_cantrips[fs]
          list << format_focus_spells(@char, charclass, fs, trad_info, spell_list, cantrip_list)
        end

        list

      end

      def format_prepared_spells(char, charclass, spell_list, trad_info)
        # Stat Block
        trad = Pf2e.pretty_string(trad_info[0])
        prof = Pf2e.pretty_string(trad_info[1].slice(0).upcase)
        atk = PF2Magic.get_spell_attack_bonus(char, charclass)

        trad_string = "#{title_color}#{charclass}%xn: #{trad} (#{prof})%b%b%bBonus: #{atk}%r%r"

        # Spell List Block
        list = []

        spell_list.each_pair do |level, splist|
          list << "#{level}: #{splist.sort.join(", ")}"
        end

        "#{trad_string}#{list.join("%r")}"
      end

      def format_spont_spells(char, charclass, spell_list, trad_info)
        # Stat Block
        trad = Pf2e.pretty_string(trad_info[0])
        prof = Pf2e.pretty_string(trad_info[1].slice(0).upcase)
        atk = PF2Magic.get_spell_attack_bonus(char, charclass)

        trad_string = "#{title_color}#{charclass}%xn: #{trad} (#{prof})%b%b%bBonus: #{atk}%r%r"

        # Spell List Block
        level_displ = []
        splist_displ = []

        spell_list.each_pair do |level, splist|
          level_displ << "#{item_color}#{level}"
          splist_displ << splist

        end

        "#{trad_string}#{level_displ.join("%b%b%b")}%r#{splist_displ.join("%b%b%b")}"
      end

      def format_focus_spells(char, charclass, fstype, trad_info, spell_list=nil, cantrip_list=nil)
        # Stat Block
        trad = Pf2e.pretty_string(trad_info[0])
        prof = Pf2e.pretty_string(trad_info[1].slice(0).upcase)
        atk = PF2Magic.get_spell_attack_bonus(char, charclass)

        trad_string = "#{title_color}#{charclass}%xn: #{trad} (#{prof})%b%b%bBonus: #{atk}%r%r"

        # Spell List Block

        cantrips = cantrip_list ? "#{item_color}Cantrips (#{fstype.capitalize}):%xn #{cantrip_list.sort.join(", ")}%r" : ""

        spells = spell_list ? "#{item_color}Focus Spells (#{fstype.capitalize}):%xn #{spell_list.sort.join(", ")}" : ""

        "#{trad_string}#{cantrips}#{spells}"
      end


    end
  end
end
