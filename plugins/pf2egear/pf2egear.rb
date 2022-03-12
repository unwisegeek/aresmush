$:.unshift File.dirname(__FILE__)

module AresMUSH
     module Pf2egear

    def self.plugin_dir
      File.dirname(__FILE__)
    end

    def self.shortcuts
      Global.read_config("pf2egear", "shortcuts")
    end

    def self.get_cmd_handler(client, cmd, enactor)
      case cmd.root
      when "pay"
        return PF2PayCmd
      when "money"
        return PF2MoneyCmd
      when "browse"
        return PF2BrowseGearCmd
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
