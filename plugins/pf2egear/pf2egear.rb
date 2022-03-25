$:.unshift File.dirname(__FILE__)

module AresMUSH
     module Pf2egear

    def self.plugin_dir
      File.dirname(__FILE__)
    end

    def self.shortcuts
      Global.read_config("pf2e_gear_options", "shortcuts")
    end

    def self.get_cmd_handler(client, cmd, enactor)
      case cmd.root
      when "pay"
        return PF2PayCmd
      when "money"
        return PF2MoneyCmd
      when "browse"
        return PF2BrowseGearCmd
      when "buy"
        return PF2BuyCmd
      when "sell"
        return PF2SellCmd
      when "gear"
        case cmd.switch
        when "rename"
          return PF2GearRenameCmd
        when "equip"
          return PF2GearEquipCmd
        when "unequip"
          return PF2GearUnequipCmd
        else
          return PF2DisplayGearCmd
        end
      when "bag"
        case cmd.switch
        when "store"
          return PF2BagStoreCmd
        else
          return PF2BagViewCmd
        end
      end

      nil
    end

    def self.get_event_handler(event_name)
      nil
    end

    def self.get_web_request_handler(request)
      nil
    end

  end
end
