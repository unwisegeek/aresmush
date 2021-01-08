$:.unshift File.dirname(__FILE__)

module AresMUSH
  module AltTracker

    def self.plugin_dir
      File.dirname(__FILE__)
    end

    def self.shortcuts
      Global.read_config("alttracker", "shortcuts")
    end

    def self.get_cmd_handler(client, cmd, enactor)
      case cmd.root
      when "register"
        case cmd.switch
        when "new"
          return RegisterNewPlayerCmd
        when "alt"
          return RegisterAltPlayerCmd
        when nil
          return RegisterPlayerCmd
        end
      when "alts"
        return ViewAltsCmd
      when "alt"
        case cmd.switch
        when "add"
          return AddAltCmd
        when "remove"
          return RemoveAltCmd
        when "ban"
          return BanPlayerCmd
        end
      when "email"
        return ChangeEmailCmd
      when "codeword"
        return ChangeCodeWordCmd
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
