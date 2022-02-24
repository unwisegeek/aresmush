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
        when "show"
          return PF2ShowSheetCmd
        else
          return PF2DisplaySheetCmd
        end
      when "award"
        case cmd.switch
        when "xp"
          return PF2AwardXPCmd
        end
      when "cg"
        case cmd.switch
        when "set"
          return PF2SetChargenCmd
        when "review"
          return PF2ReviewChargenCmd
        when "reset"
          return PF2ResetChargenCmd
        when "info"
          return PF2ChargenInfoCmd
        end
      when "commit"
        case cmd.args
        when "info"
          return PF2CommitInfoCmd
        when "abilities"
          return PF2CommitAbilCmd
        end
      when "roll"
        case cmd.switch
        when nil, "me"
          return PF2RollCommand
        when "for"
          return PF2RollForCommand
        when "listalias"
          return PF2ListRollAliasCmd
        when "alias"
          return PF2ChangeRollAliasCmd
        end
      when "boost"
        case cmd.switch
        when "set"
          return PF2BoostSetCmd
        when "unset"
          return PF2BoostUnsetCmd
        end
      when "skill"
        case cmd.switch
        when "set"
          return PF2SkillSetCmd
        when "unset"
          return PF2SkillUnSetCmd
        end
      when "lore"
        case cmd.switch
        when "set"
          return PF2LoreSetCmd
        when "unset"
          return PF2LoreUnSetCmd
        when "info"
          return PF2LoreInfoCmd
        end
      when "lang"
        case cmd.switch
        when "set"
          return PF2LanguageSetCmd
        when "info"
          return PF2LanguageInfoCmd
        when "unset"
          return PF2LanguageUnSetCmd
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
