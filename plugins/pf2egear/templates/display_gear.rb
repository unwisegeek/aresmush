module AresMUSH
  module Pf2egear

    class Pf2eDisplayGearTemplate < ErbTemplateRenderer
      include CommonTemplateFields

      attr_accessor :char

      def initialize(char, client)
        @char = char
        @client = client

        super File.dirname(__FILE__) + "/display_gear.erb"
      end

      def section_line(title)
        @client.screen_reader ? title : line_with_text(title)
      end

      def weapons
        list = []

        weapon_list = @char.weapons ? @char.weapons  : []

        @weapon_bulk = weapon_list.map { |wp| wp.bulk }.sum

        weapon_list.each_with_index do |wp,i|
          list << format_wp(@char,wp,i)
        end

        list
      end

      def armor
        list = []

        armor_list = @char.armor ? @char.armor : []

        @armor_bulk = armor_list.map { |a| a.bulk }.sum

        armor_list.each_with_index do |a,i|
          list << format_armor(@char,a,i)
        end

        list
      end

      def shields
        list = []

        shields_list = @char.shields ? @char.shields : []

        @shields_bulk = shields_list.map { |s| s.bulk }.sum

        shields_list.each_with_index do |s,i|
          list << format_shields(@char,s,i)
        end

        list
      end

      def consumables
        list = []

        con_list = @char.pf2_gear['consumables'] ? @char.pf2_gear['consumables'] : {}

        char_cons_list = con_list.keys

        game_cons_list = Global.read_config('pf2e_consumables')

        cons_bulk = []

        char_cons_list.each do |item|
          cons_bulk << game_cons_list[item]['bulk']
        end

        @consumables_bulk = cons_bulk.sum

        con_list.each_with_index do |name,qty,i|
          list << format_cons(name, qty, i)
        end

        list
      end

      def gear_list
        list = []

        con_list = @char.pf2_gear['gear'] ? @char.pf2_gear['gear'] : {}

        char_glist = con_list.keys

        game_glist = Global.read_config('pf2e_gear')

        gbulk = []

        char_glist.each do |item|
          gbulk << game_glist[item]['bulk']
        end

        @gear_bulk = gbulk.sum

        con_list.each_with_index do |name,qty,i|
          list << format_cons(name, qty, i)
        end

        list
      end

      def total_bulk
        @weapon_bulk + @armor_bulk + @consumables_bulk + @gear_bulk
      end

      def header_wp_armor
        "%b%b#{left("#", 3)}%b#{left("Name", 63)}%b#{left("Bulk", 4)}%b#{left("Prof", 4)}"
      end

      def format_wp(char,w,i)
        name = w.nickname ? "#{w.nickname} (#{w.name})" : w.name
        bulk = w.bulk == 0.1 ? "L" : w.bulk.to_i
        prof = Pf2eCombat.get_weapon_prof(char, w.name)[0].upcase
        "%b%b#{left(i, 3)}%b#{left(name, 63)}%b#{left(bulk, 4)}%b#{left(prof, 4)}"
      end

      def format_armor(char,a,i)
        name = a.nickname ? "#{a.nickname} (#{a.name})" : a.name
        bulk = a.bulk == 0.1 ? "L" : a.bulk.to_i
        prof = Pf2eCombat.get_armor_prof(char, a.name)[0].upcase
        "%b%b#{left(i, 3)}%b#{left(name, 63)}%b#{left(bulk, 3)}%b#{left(prof, 3)}"
      end

      def header_shields
        "%b%b#{left("#", 3)}%b#{left("Name", 56)}%b#{left("Bulk", 4)}%b#{left("HP", 10)}"
      end

      def format_shields(char,s,i)
        name = s.nickname ? "#{s.nickname} (#{s.name})" : s.name
        bulk = s.bulk == 0.1 ? "L" : s.bulk.to_i
        hp = s.hp
        dmg = s.damage
        cur_hp = hp - dmg
        broken = (cur_hp * 2 >= hp) ? "%xr" : ""
        disp_hp = "#{broken}#{cur_hp}%xn / #{hp}"

        "%b%b#{left(i, 3)}%b#{left(name, 55)}%b#{left(bulk, 4)}%b#{left(disp_hp,10)}"
      end

      def format_cons(name,qty,i)
        linebreak = i % 2 == 1 ? "" : "%r"
        "#{linebreak}#{left(name, 32)} - #{right(qty,3)}%b"
      end
    end

  end
end
