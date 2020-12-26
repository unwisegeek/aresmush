module AresMUSH
  module AltTracker
    class AltDisplayTemplate < ErbTemplateRenderer

      attr_accessor :email, :codeword, :altlist, :banned

      def initialize(email, codeword, altlist, banned=nil)
        @email = email
        @codeword = codeword
        @altlist = altlist
        @banned = banned
        super File.dirname(__FILE__) + "/alt_display.erb"

      def player_email
        @email
      end

      def player_codeword
        @codeword
      end

      def player_altlist
        @altlist
      end

      def banned
        @banned
      end

    end
  end
end
