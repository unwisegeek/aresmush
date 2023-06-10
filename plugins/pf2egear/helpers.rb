module AresMUSH
  module Pf2egear

    def self.convert_money(value, type)
      case type
      when "platinum", "pp"
        multiplier = 1000
      when "gold", "gp"
        multiplier = 100
      when "silver", "sp"
        multiplier = 10
      when "copper", "cp"
        multiplier = 1
      else
        return nil
      end

      value * multiplier
    end

    def self.display_money(money)
      cp = money % 10
      sp = (money/10) % 10
      gp = (money/100) % 10
      pp = (money/1000)

      cp_msg = cp > 0 ? " #{cp} cp " : " "
      sp_msg = sp > 0 ? " #{sp} sp " : " "
      gp_msg = gp > 0 ? " #{gp} gp " : " "
      pp_msg = pp > 0 ? " #{pp} pp " : " "

      msg = pp_msg + gp_msg + sp_msg + cp_msg
      msg.squeeze(" ").strip
    end

    def self.pay_player(char, amount)
      purse = char.pf2_money
      char.update(pf2_money: purse + amount)
    end

    def self.reset_gear(char)
      char.pf2_gear = {'consumables' => {}, 'gear' => {}}
      char.pf2_money = 1500

      char.weapons&.each { |i| i.delete }
      char.armor&.each { |i| i.delete }
      char.bags&.each { |i| i.delete }
      char.shields&.each { |i| i.delete }
      char.magic_items&.each { |i| i.delete }
      char.gear&.each { |i| i.delete }
      char.consumables&.each { |i| i.delete }

      char.save
    end

    def self.display_shield_hp(item)
      hp = item.hp
      dmg = item.damage
      cur_hp = hp - dmg
      broken = (cur_hp <= hp / 2) ? "%xr" : ""

      "#{broken}#{cur_hp}%xn / #{hp}"
    end

    def self.items_in_inventory(list)
      list.filter { |item| !(item.bag) }
    end

    def self.bag_effective_bulk(bag, load)
      max_capacity = bag.capacity
      capacity_bonus = bag.bulk_bonus ? bag.bulk_bonus : 0
      bag_bulk = bag.bulk

      char_bulk = (load + bag_bulk - capacity_bonus).to_i.clamp(0,100)
    end

    def self.calculate_bag_load(bag)
      wp_load = bag.weapons.map { |w| w.bulk }.sum
      armor_load = bag.armor.map { |a| a.bulk }.sum
      shield_load = bag.shields.map { |s| s.bulk }.sum
      mi_load = bag.magicitem.map { |m| m.bulk }.sum
      c_load = bag.consumables.map { |c| c.bulk }.sum
      gear_load = bag.gear.map { |g| g.bulk }.sum

      wp_load + armor_load + shield_load + mi_load + c_load + gear_load
    end

    def self.invested_items(char)
      magic_items = char.magic_items.select { |item| item.invested }.to_a
      weapons = char.weapons.select { |item| item.invested }.to_a
      armor = char.magic_items.select { |item| item.invested }.to_a

      magic_items + weapons + armor
    end

    def self.create_item(char, category, name, quantity, item_info)

      source_type = AresMUSH.const_get(Global.read_config('pf2e_gear_options', 'item_classes', category))

      case category
      when "weapons", "weapon", "armor", "shields", "shield", "bags", "magicitem"

        new_item = source_type.create(character: char, name: name)

        item_info.each_pair do |k,v|
          new_item.update("#{k}": v)
        end

      when "consumables", "gear"

        ilist = category == "gear" ? char.gear : char.consumables

        has_item = ilist.select { |item| item.name == name }.first

        if has_item
          old_qty = has_item.quantity
          has_item.update(quantity: quantity + old_qty)
        else
          new_item = source_type.create(character: char, name: name)
            item_info.each_pair do |k,v|
              new_item.update("#{k}": v)
            end

          new_item.update(quantity: quantity)
        end

      end

    end

    def self.get_item_name(item)
      item.nickname ? "#{item.nickname} (#{item.name})" : item.name
    end

  end
end
