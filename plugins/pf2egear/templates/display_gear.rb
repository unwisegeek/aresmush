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

        wp_list = @char.weapons ? Pf2egear.items_in_inventory(@char.weapons.to_a)  : []

        @weapon_bulk = wp_list.map { |wp| wp.bulk }.sum

        wp_list.each_with_index do |wp,i|
          list << format_wp(@char,wp,i)
        end

        list
      end

      def armor
        list = []

        armor_list = @char.armor ? Pf2egear.items_in_inventory(@char.armor.to_a) : []

        @armor_bulk = armor_list.map { |a| a.bulk }.sum

        armor_list.each_with_index do |a,i|
          list << format_armor(@char,a,i)
        end

        list
      end

      def shields
        list = []

        shields_list = @char.shields ? Pf2egear.items_in_inventory(@char.shields.to_a) : []

        @shields_bulk = shields_list.map { |s| s.bulk }.sum

        shields_list.each_with_index do |s,i|
          list << format_shields(@char,s,i)
        end

        list
      end

      def consumables
        list = []

        consumables_list = @char.consumables ? Pf2egear.items_in_inventory(@char.consumables.to_a) : []

        @consumables_bulk = consumables_list.map { |c| c.bulk }.sum

        consumables_list.each_with_index do |c,i|
          list << format_gear(c,i)
        end

        list
      end

      def bags
        list = []

        bags = @char.bags ? @char.bags : []

        blist = bags.map do |b|
          Pf2egear.bag_effective_bulk b, Pf2egear.calculate_bag_load(b)
        end

        @bag_bulk = blist.sum

        bags.each_with_index do |b,i|
          list << format_bags(b,i)
        end

        list
      end

      def gear
        list = []

        gear_list = @char.gear ? Pf2egear.items_in_inventory(@char.gear.to_a) : []

        @gear_bulk = gear_list.map { |g| g.bulk }.sum

        gear_list.each_with_index do |g,i|
          list << format_gear(g,i)
        end

        list
      end

      def use_encumbrance
        Global.read_config('pf2e_gear_options', 'use_encumbrance')
      end

      def encumbrance
        char_strmod = Pf2eAbilities.abilmod(Pf2eAbilities.get_score(@char, "Strength"))

        current_bulk = @weapon_bulk + @armor_bulk + @shields_bulk + @consumables_bulk + @gear_bulk + @bag_bulk

        max_capacity = 10 + char_strmod
        encumbered = 5 + char_strmod

        enc_state = current_bulk >= encumbered ? "%xh%xyEncumbered%xn" : "%xgUnencumbered%xn"

        "#{item_color}Current Bulk:%xn #{current_bulk.to_i} / #{max_capacity} (#{enc_state})"
      end

      def money
        Pf2egear.display_money(@char.pf2_money)
      end

      def header_wp_armor
        "%b%b#{left("#", 3)}%b#{left("Name", 43)}%b#{left("Bulk", 8)}%b#{left("Prof", 10)}%b#{left("Equip?", 9)}"
      end

      def format_wp(char,w,i)
        name = w.nickname ? "#{w.nickname} (#{w.name})" : w.name
        bulk = w.bulk == 0.1 ? "L" : w.bulk.to_i
        prof = Pf2eCombat.get_weapon_prof(char, w.name)[0].upcase
        equip = w.equipped ? "Yes" : "No"
        "%b%b#{left(i, 3)}%b#{left(name, 43)}%b#{left(bulk, 8)}%b#{left(prof, 10)}%b#{left(equip, 9)}"
      end

      def format_armor(char,a,i)
        name = a.nickname ? "#{a.nickname} (#{a.name})" : a.name
        bulk = a.bulk == 0.1 ? "L" : a.bulk.to_i
        prof = Pf2eCombat.get_armor_prof(char, a.name)[0].upcase
        equip = a.equipped ? "Yes" : "No"
        "%b%b#{left(i, 3)}%b#{left(name, 43)}%b#{left(bulk, 8)}%b#{left(prof, 10)}%b#{left(equip, 9)}"
      end

      def header_shields
        "%b%b#{left("#", 3)}%b#{left("Name", 43)}%b#{left("Bulk", 8)}%b#{left("HP", 10)}%b#{left("Equip?", 9)}"
      end

      def format_shields(char,s,i)
        name = s.nickname ? "#{s.nickname} (#{s.name})" : s.name
        bulk = s.bulk == 0.1 ? "L" : s.bulk.to_i
        hp = s.hp
        dmg = s.damage
        cur_hp = hp - dmg
        broken = (cur_hp <= hp / 2) ? "%xr" : ""
        disp_hp = "#{broken}#{cur_hp}%xn / #{hp}"
        equip = s.equipped ? "Yes" : "No"

        "%b%b#{left(i, 3)}%b#{left(name, 43)}%b#{left(bulk, 8)}%b#{left(disp_hp,10)}%b#{left(equip, 9)}"
      end

      def format_gear(item,i)
        qty = (item.quantity) > 99 ? item.quantity : "99+"
        name = item.name
        linebreak = i % 2 == 1 ? "" : "%r"
        "#{linebreak}#{left(i, 3)}%b#{left(name, 28)}: #{left(qty,3)} "
      end

      def header_bags
        "%b%b#{left("#", 3)}%b#{left("Name", 55)}%b#{left("Current Load", 12)}"
      end

      def format_bags(bag, i)
        name = bag.nickname ? "#{bag.nickname} (#{bag.name})" : bag.name
        capacity = bag.capacity
        current_load = Pf2egear.calculate_bag_load(bag)
        disp_load = "#{current_load} / #{capacity}"

        "%b%b#{left(i, 3)}%b#{left(name, 55)}%b#{left(disp_load, 12)}"
      end


    end

  end
end
