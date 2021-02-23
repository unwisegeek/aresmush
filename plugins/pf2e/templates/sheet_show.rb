module AresMUSH
  module Pf2e
    class PF2SheetPermissions < ErbTemplateRenderer
      include CommonTemplateFields

      attr_accessor :permissions

      def initialize(permissions)
        @permissions = permissions

        super File.dirname(__FILE__) + "/sheet_show.erb"
      end

      def permissions
        @permissions
      end
      
    end
  end
end
