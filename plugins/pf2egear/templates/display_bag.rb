module AresMUSH
  module Pf2egear

    class PF2BagTemplate < ErbTemplateRenderer
      include CommonTemplateFields

      attr_accessor :char, :bag, :client

      def initialize(char, bag, client)
        @char = char
        @bag = bag
        @client = client

        super File.dirname(__FILE__) + "/display_bag.erb"
      end

      def section_line(title)
        @client.screen_reader ? title : line_with_text(title)
      end

      def bag_title
        t('pf2egear.bag_title', :bagname => @bag.name)
      end

      def weapons
        list = []

        weapon_list = @bag.weapons ? @bag.weapons : []

        @weapon_bulk = weapon_list.map { |wp| wp.bulk }.sum

        weapon_list.each_with_index do |wp,i|
          list << format_wp(@char,wp,i)
        end

        list
      end

      def armor
        list = []

        armor_list = @bag.armor ? @bag.armor : []

        @armor_bulk = armor_list.map { |a| a.bulk }.sum

        armor_list.each_with_index do |a,i|
          list << format_armor(@char,a,i)
        end

        list
      end

      def shields
        list = []

        shields_list = @bag.shields ? @bag.shields : []

        @shields_bulk = shields_list.map { |s| s.bulk }.sum

        shields_list.each_with_index do |s,i|
          list << format_shields(s,i)
        end

        list
      end

      def consumables
        list = []

        consumables_list = @bag.consumables ? @bag.consumables.to_a : []

        consumables_list.each_with_index do |c,i|
          list << format_gear(c,i)
        end

        list
      end

      def gear
        list = []

        gear_list = @bag.gear ? @bag.gear.to_a : []

        gear_list.each_with_index do |g,i|
          list << format_gear(g,i)
        end

        list
      end

      def use_encumbrance
        Global.read_config('pf2e_gear_options', 'use_encumbrance')
      end

      def encumbrance

        current_load = Pf2egear.calculate_bag_load(@bag)

        bag_bulk = Pf2egear.bag_effective_bulk(@bag, current_load)

        "#{item_color}Capacity:%xn #{current_load} / #{max_capacity}    #{item_color}Character Load%xn: #{bag_bulk}"
      end

      def header_wp_armor
        "%b%b#{left("#", 3)}%b#{left("Name", 45)}%b#{left("Bulk", 8)}%b#{left("Prof", 12)}"
      end

      def format_wp(char,w,i)
        name = w.nickname ? "#{w.nickname} (#{w.name})" : w.name
        bulk = w.bulk == 0.1 ? "L" : w.bulk.to_i
        prof = Pf2eCombat.get_weapon_prof(char, w.name)[0].upcase
        "%b%b#{left(i, 3)}%b#{left(name, 45)}%b#{left(bulk, 8)}%b#{left(prof, 12)}"
      end

      def format_armor(char,a,i)
        name = a.nickname ? "#{a.nickname} (#{a.name})" : a.name
        bulk = a.bulk == 0.1 ? "L" : a.bulk.to_i
        prof = Pf2eCombat.get_armor_prof(char, a.name)[0].upcase
        "%b%b#{left(i, 3)}%b#{left(name, 45)}%b#{left(bulk, 8)}%b#{left(prof, 12)}"
      end

      def header_shields
        "%b%b#{left("#", 3)}%b#{left("Name", 45)}%b#{left("Bulk", 8)}%b#{left("HP", 12)}"
      end

      def format_shields(s,i)
        name = s.nickname ? "#{s.nickname} (#{s.name})" : s.name
        bulk = s.bulk == 0.1 ? "L" : s.bulk.to_i
        hp = s.hp
        dmg = s.damage
        cur_hp = hp - dmg
        broken = (cur_hp <= hp / 2) ? "%xr" : ""
        disp_hp = "#{broken}#{cur_hp}%xn / #{hp}"

        "%b%b#{left(i, 3)}%b#{left(name, 45)}%b#{left(bulk, 8)}%b#{left(disp_hp,12)}"
      end

      def format_gear(item,i)
        qty = item.quantity > 99 ? item.quantity : "99+"
        name = item.name
        linebreak = i % 2 == 1 ? "" : "%r"
        "#{linebreak}#{left(i, 3)}%b#{left(name, 28)}: #{left(qty,3)} "
      end
    end

  end
end
