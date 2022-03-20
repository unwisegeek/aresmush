module AresMUSH
  module Pf2egear

    class PF2BagTemplate < ErbTemplateRenderer
      include CommonTemplateFields

      attr_accessor :bag, :client

      def initialize(bag, client)
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
          list << format_wp(@bag,wp,i)
        end

        list
      end

      def armor
        list = []

        armor_list = @bag.armor ? @bag.armor : []

        @armor_bulk = armor_list.map { |a| a.bulk }.sum

        armor_list.each_with_index do |a,i|
          list << format_armor(@bag,a,i)
        end

        list
      end

      def shields
        list = []

        shields_list = @bag.shields ? @bag.shields : []

        @shields_bulk = shields_list.map { |s| s.bulk }.sum

        shields_list.each_with_index do |s,i|
          list << format_shields(@bag,s,i)
        end

        list
      end

      def consumables
        list = []

        con_list = @bag.gear_contents['consumables'] ? @bag.gear_contents['consumables'] : {}

        char_cons_list = con_list.keys

        game_cons_list = Global.read_config('pf2e_consumables')

        cons_bulk = []

        if !(char_cons_list.empty?)
          char_cons_list.each_with_index do |item, i|
            cons_bulk << game_cons_list[item]['bulk']

            qty = con_list[item]
            list << format_cons(item, qty, i)
          end
        end

        @consumables_bulk = cons_bulk.empty? ? cons_bulk.sum : 0

        list
      end

      def gear_list
        list = []

        con_list = @bag.gear_contents['gear'] ? @bag.gear_contents['gear'] : {}

        char_glist = con_list.keys

        game_glist = Global.read_config('pf2e_gear')

        gbulk = []

        if !(char_glist.empty?)
          char_glist.each_with_index do |item, i|
            gbulk << game_glist[item]['bulk']

            qty = con_list[item]
            list << format_cons(item, qty, i)
          end
        end

        @gear_bulk = gbulk.empty? ? gbulk.sum : 0

        list
      end

      def use_encumbrance
        Global.read_config('pf2e_gear_options', 'use_encumbrance')
      end

      def encumbrance

        current_load = @weapon_bulk + @armor_bulk + @shields_bulk + @consumables_bulk + @gear_bulk

        max_capacity = @bag.capacity
        capacity_bonus = @bag.bulk_bonus ? @bag.bulk_bonus : 0
        bag_bulk = @bag.bulk

        char_bulk = current_load + bag_bulk - capacity_bonus.clamp(0,100)

        "#{item_color}Capacity:%xn #{current_load} / #{max_capacity}    Character Load: #{char_bulk}"
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

      def format_shields(char,s,i)
        name = s.nickname ? "#{s.nickname} (#{s.name})" : s.name
        bulk = s.bulk == 0.1 ? "L" : s.bulk.to_i
        hp = s.hp
        dmg = s.damage
        cur_hp = hp - dmg
        broken = (cur_hp <= hp / 2) ? "%xr" : ""
        disp_hp = "#{broken}#{cur_hp}%xn / #{hp}"

        "%b%b#{left(i, 3)}%b#{left(name, 45)}%b#{left(bulk, 8)}%b#{left(disp_hp,12)}"
      end

      def format_cons(name,qty,i)
        linebreak = i % 2 == 1 ? "" : "%r"
        "#{linebreak}#{left(name, 32)}: #{left(qty,3)} "
      end
    end

  end
end
