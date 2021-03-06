$:.unshift File.dirname(__FILE__)

module AresMUSH
  module Pf2e

    def self.plugin_dir
      File.dirname(__FILE__)
    end

    def self.shortcuts
      Global.read_config("pf2e", "shortcuts")
    end

    def self.get_cmd_handler(client, cmd, enactor)
      case cmd.root
      when "sheet"
        case cmd.switch
        when nil, "info", "top", "ability", "combat", "skills", "feats", "features", "languages"
          return DisplaySheetCmd
        when "show"
          return PF2ShowSheetCmd
        end
      when "cg"
        case cmd.switch
        when "set"
          return PF2SetChargenCmd
        when "review"
          return PF2ReviewChargenCmd
        when "reset"
          return PF2ResetChargenCmd

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
