module AresMUSH
  module Pf2e

    class PF2CombatSheetTemplate < ErbTemplateRenderer
      include CommonTemplateFields

      attr_accessor :char, :client

      def initialize(char, client)
        @char = char
        @client = client

        super File.dirname(__FILE__) + "/csheet_template.erb"
      end

      def section_line(title)
        @client.screen_reader ? title : line_with_text(title)
      end

      def combat_stats
        @char.combat
      end

      def hp
        hp = @char.hp

        return "---" if !hp

        current = Pf2eHP.get_current_hp(@char)
        max = Pf2eHP.get_max_hp(@char)
        percent = max.zero? ? 0 : (current / max) * 100.floor
        hp_color = "%xg" if percent > 75
        hp_color = "%xc" if percent.between?(50,75)
        hp_color = "%xy" if percent.between?(25,50)
        hp_color = "%xr" if percent < 25
        "#{hp_color}#{current}%xn / #{max} (#{percent}%)"
      end

      def temp_hp
        hp = @char.hp

        return "---" if !hp

        has_temp_hp = hp.temp_max

        return "None." if !has_temp_hp

        current = hp.temp_current
        max = hp.temp_max
        "#{current}%xn / #{max}"
      end

      def class_dc
        return "--" if !combat_stats
        dc = Pf2eCombat.get_class_dc(@char)
        prof = combat_stats.class_dc[0].upcase
        "#{dc} (#{prof})"
      end

      def perception
        return "--" if !combat_stats
        bonus = Pf2eCombat.get_perception(@char)
        prof = combat_stats.perception[0].upcase
        "#{bonus} (#{prof})"
      end

      def saves
        saves = %w{fortitude reflex will}
        list = []
        saves.each do |s|
          list << format_save(@char, s)
        end

        list
      end

      def ac
        armor = @char.armor&.select { |a| a.equipped }.first

        abonus = armor ? armor.ac_bonus : 0
        a_cat = armor ? armor.category : "unarmored"
        prof_with_armor = combat_stats.armor_prof[a_cat]
        pbonus = Pf2e.get_prof_bonus(prof_with_armor)

        ibonus = Pf2e.bonus_from_item(char, "ac")

        dex_cap = armor ? armor.dex_cap : 99
        dbonus = Pf2eAbilities.abilmod(Pf2eAbilities.get_score(char, 'Dexterity')).clamp(-99, dex_cap)

        ac = 10 + abonus + pbonus + ibonus + dbonus
      end

      def unarmed_attacks

        unarmed_prof = combat_stats.weapon_prof['unarmed']
        list = []

        attack_list = combat_stats.unarmed_attacks.sort

        attack_list.each do |atk, info|
          list << format_unarmed(@char, atk, info, unarmed_prof)
        end

        list
      end

      def weapons
        weapon_list = Pf2egear.items_in_inventory(@char.weapons)

        list = []

        weapon_list.each_with_index do |w,i|
          next if !w.equipped

          list << format_weapon(char, w, i)
        end

        list
      end

      def format_weapon(char,w,i)
        name = w.nickname ? "#{w.nickname} (#{w.name})" : w.name
        bonus = Pf2eCombat.get_wpattack_bonus(char, w)
        prof = Pf2eCombat.get_weapon_prof(char, w.name)[0].upcase
        damage = Pf2eCombat.get_damage(char, w.name, w)

        "%b%b#{left(i, 3)}%b#{left(name, 40)}%b#{left("#{bonus} (#{prof})",10)}%b#{left(damage, 15)}"
      end

      def format_save(char,name)
        save = "#{item_color}#{name.capitalize}%xn"
        prof = Pf2eCombat.get_save_from_char(char, name)[0].upcase
        bonus = Pf2eCombat.get_save_bonus(char, name)
        "#{left("#{save}: #{bonus} (#{prof})", 26)}"
      end

      def format_unarmed(char, atk_name, atk_info, unarmed_prof)

        # UNFINISHED
      end

    end
  end
end
